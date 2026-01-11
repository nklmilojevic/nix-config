# Cloud provider tools
{pkgs}:
with pkgs; [
  (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
  opentofu
  cloudflared
  steampipe
]
