#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME --type TYPE [--region REGION] [--limit N] [--profile PROFILE] [--json-out FILE] [--platform PLATFORM] [--free-tier-only]

Supported types:
  rhel        RHEL 9 GA style images (RHEL-9*), Red Hat owner 309956199498
  rhel9       Explicit alias for RHEL 9 GA (same as rhel)
  rhel10      RHEL 10 GA style images (RHEL-10*), Red Hat owner 309956199498
  rhel_suse   All images with platform-details Red Hat Enterprise Linux or SUSE Linux
  rhel9_std   Experimental: console style RHEL 9 entries (uses description, may need --name-filter)
  rhel10_std  Experimental: console style RHEL 10 entries (uses description, may need --name-filter)

Platforms (via --platform):
  rhel        platform-details: Red Hat Enterprise Linux
  suse        platform-details: SUSE Linux
  ubuntu      platform-details: Ubuntu
  debian      platform-details: Debian
  amazon      platform-details: Linux/UNIX (broad, usually combine with owner)
  windows     platform: windows

Examples:
  $SCRIPT_NAME --type rhel10 --region eu-north-1
  $SCRIPT_NAME --type rhel_suse --region eu-north-1 --limit 20
  $SCRIPT_NAME --platform suse --region eu-north-1
  $SCRIPT_NAME --type rhel10 --region us-east-1 --free-tier-only
  $SCRIPT_NAME --type rhel10 --region us-east-1 --json-out ./output/rhel10_us_e1.json

Options:
  --type TYPE         AMI type shortcut (see above)
  --platform PLATFORM Platform shortcut (rhel, suse, ubuntu, debian, amazon, windows)
  --region REGION     AWS region (default from AWS_REGION or eu-north-1)
  --limit N           Number of images to show in the table (default 5)
  --profile PROFILE   AWS CLI profile to use
  --owner OWNER       Override AMI owner ID (if omitted, no --owners filter is used)
  --name-filter PAT   Override the main filter pattern (name, description or platform-details)
  --json-out FILE     Write JSON output (slimmed projection) to this file
  --free-tier-only    Only keep images where FreeTierEligible == true (client side filter)
  --help              Show this help
EOF
}

# Defaults
TYPE=""
PLATFORM=""
REGION="${AWS_REGION:-eu-north-1}"
LIMIT=5
PROFILE=""
OWNER=""
NAME_FILTER=""
FILTER_KEY="name"
JSON_OUT=""
FREE_TIER_ONLY="false"

PLATFORM_FILTER_KEY=""
PLATFORM_FILTER_VALUE=""

# Load .env if present
if [[ -f ".env" ]]; then
  set -o allexport
  # shellcheck disable=SC1091
  source .env
  set +o allexport

  REGION="${REGION:-${AWS_REGION:-eu-north-1}}"
fi

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="${2:-}"
      shift 2
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --region)
      REGION="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --owner)
      OWNER="${2:-}"
      shift 2
      ;;
    --name-filter)
      NAME_FILTER="${2:-}"
      shift 2
      ;;
    --json-out)
      JSON_OUT="${2:-}"
      shift 2
      ;;
    --free-tier-only)
      FREE_TIER_ONLY="true"
      shift 1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TYPE" && -z "$PLATFORM" ]]; then
  echo "Error: at least one of --type or --platform is required" >&2
  usage
  exit 1
fi

if [[ -z "$REGION" ]]; then
  echo "Error: region is empty. Set AWS_REGION, use --region, or ensure .env sets it." >&2
  exit 1
fi

# Map TYPE → base filter
if [[ -n "$TYPE" ]]; then
  case "$TYPE" in
    rhel)
      OWNER="${OWNER:-309956199498}"
      FILTER_KEY="name"
      NAME_FILTER="${NAME_FILTER:-RHEL-9*}"
      ;;
    rhel9)
      OWNER="${OWNER:-309956199498}"
      FILTER_KEY="name"
      NAME_FILTER="${NAME_FILTER:-RHEL-9*}"
      ;;
    rhel10)
      OWNER="${OWNER:-309956199498}"
      FILTER_KEY="name"
      NAME_FILTER="${NAME_FILTER:-RHEL-10*}"
      ;;
    rhel_suse)
      OWNER=""
      FILTER_KEY="platform-details"
      NAME_FILTER="${NAME_FILTER:-Red Hat Enterprise Linux,SUSE Linux}"
      ;;
    rhel9_std)
      OWNER=""
      FILTER_KEY="description"
      NAME_FILTER="${NAME_FILTER:-Red Hat Enterprise Linux 9 (HVM), SSD Volume Type*}"
      ;;
    rhel10_std)
      OWNER=""
      FILTER_KEY="description"
      NAME_FILTER="${NAME_FILTER:-Red Hat Enterprise Linux 10 (HVM), SSD Volume Type*}"
      ;;
    *)
      echo "Error: unsupported type '$TYPE'." >&2
      echo "Supported types: rhel, rhel9, rhel10, rhel_suse, rhel9_std, rhel10_std." >&2
      exit 1
      ;;
  esac
else
  FILTER_KEY="name"
  NAME_FILTER="${NAME_FILTER:-*}"
fi

# Map PLATFORM → platform-details/platform filter
if [[ -n "$PLATFORM" ]]; then
  case "$PLATFORM" in
    rhel)
      PLATFORM_FILTER_KEY="platform-details"
      PLATFORM_FILTER_VALUE="Red Hat Enterprise Linux"
      ;;
    suse)
      PLATFORM_FILTER_KEY="platform-details"
      PLATFORM_FILTER_VALUE="SUSE Linux"
      ;;
    ubuntu)
      PLATFORM_FILTER_KEY="platform-details"
      PLATFORM_FILTER_VALUE="Ubuntu"
      ;;
    debian)
      PLATFORM_FILTER_KEY="platform-details"
      PLATFORM_FILTER_VALUE="Debian"
      ;;
    amazon)
      PLATFORM_FILTER_KEY="platform-details"
      PLATFORM_FILTER_VALUE="Linux/UNIX"
      ;;
    windows)
      PLATFORM_FILTER_KEY="platform"
      PLATFORM_FILTER_VALUE="windows"
      ;;
    *)
      echo "Unknown platform '$PLATFORM'." >&2
      echo "Supported platforms: rhel, suse, ubuntu, debian, amazon, windows." >&2
      exit 1
      ;;
  esac
fi

# Tool checks
if ! command -v aws >/dev/null 2>&1; then
  echo "Error: aws CLI not found in PATH." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required for output formatting." >&2
  exit 1
fi

echo "Looking up AMIs..."
echo "  Type            : ${TYPE:-<none>}"
echo "  Platform        : ${PLATFORM:-<none>}"
echo "  Region          : $REGION"
echo "  Owner           : ${OWNER:-<none>}"
echo "  Base filter key : $FILTER_KEY"
echo "  Base filter val : $NAME_FILTER"
if [[ -n "$PLATFORM_FILTER_KEY" ]]; then
  echo "  Platform key    : $PLATFORM_FILTER_KEY"
  echo "  Platform value  : $PLATFORM_FILTER_VALUE"
fi
echo "  Free tier only  : $FREE_TIER_ONLY"
echo "  Limit           : $LIMIT"
echo

AWS_ARGS=(
  ec2 describe-images
  --region "$REGION"
  --filters
  "Name=${FILTER_KEY},Values=${NAME_FILTER}"
  "Name=architecture,Values=x86_64"
  "Name=virtualization-type,Values=hvm"
  "Name=root-device-type,Values=ebs"
)

if [[ -n "$PLATFORM_FILTER_KEY" ]]; then
  AWS_ARGS+=( "Name=${PLATFORM_FILTER_KEY},Values=${PLATFORM_FILTER_VALUE}" )
fi

AWS_ARGS+=( --query "Images" --output json )

if [[ -n "$OWNER" ]]; then
  AWS_ARGS+=( --owners "$OWNER" )
fi

if [[ -n "$PROFILE" ]]; then
  AWS_ARGS+=( --profile "$PROFILE" )
fi

FULL_JSON="$(aws "${AWS_ARGS[@]}")"

# Optional client side filter on FreeTierEligible
if [[ "$FREE_TIER_ONLY" == "true" ]]; then
  FILTERED_JSON="$(echo "$FULL_JSON" | jq '[.[] | select(.FreeTierEligible == true)]')"
else
  FILTERED_JSON="$FULL_JSON"
fi

if [[ "$(echo "$FILTERED_JSON" | jq 'length')" -eq 0 ]]; then
  echo "No images found for filters:"
  echo "  owner               = ${OWNER:-<none>}"
  echo "  ${FILTER_KEY}       = $NAME_FILTER"
  if [[ -n "$PLATFORM_FILTER_KEY" ]]; then
    echo "  ${PLATFORM_FILTER_KEY} = $PLATFORM_FILTER_VALUE"
  fi
  echo "  free tier only      = $FREE_TIER_ONLY"
  echo "  region              = $REGION"
  echo
  echo "Hint:"
  echo "  Try inspecting a known AMI directly with:"
  echo "    aws ec2 describe-images --image-ids <ami-id> --region $REGION"
  echo "  then refine --name-filter, --type, --platform or drop --free-tier-only."
  exit 1
fi

# Slim projection: keep only the essentials
IMAGES_JSON="$(echo "$FILTERED_JSON" | jq '[.[] | {
  ImageId,
  Name,
  PlatformDetails,
  Description,
  Hypervisor,
  SourceImageId,
  SourceImageRegion,
  FreeTierEligible,
  State,
  Architecture,
  CreationDate
}]')"

if [[ -z "$JSON_OUT" ]]; then
  JSON_OUT="ami_${TYPE:-generic}_${PLATFORM:-all}_${REGION}.json"
fi

echo "$IMAGES_JSON" | jq '.' > "$JSON_OUT"

echo "Slim JSON written to: $JSON_OUT"
echo
echo "Available AMIs (newest first, limited to $LIMIT):"
echo

echo "$IMAGES_JSON" \
  | jq -r --argjson limit "$LIMIT" '
      sort_by(.CreationDate) | reverse | .[0:$limit]
      | (["ImageId","FreeTier","PlatformDetails","CreationDate","Name"] | @tsv),
        (.[] | [.ImageId, (if .FreeTierEligible then "true" else "false" end), (.PlatformDetails // ""), .CreationDate, .Name] | @tsv)
    ' \
  | column -t -s $'\t'

echo
echo "Tip:"
echo "  Use one of the Name values or a pattern (for example RHEL-10.1.0_HVM_GA-*)"
echo "  as ami_name_prefix or ami_name_patterns in your Terraform data aws_ami."
echo "  The JSON file contains a compact, script friendly view of each image."
