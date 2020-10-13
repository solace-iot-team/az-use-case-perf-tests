
{
  "env":
  ${jsonencode(
    {
      "zone": "${zone}",
      "proximity_placement_group": {
        "id": "${ppg_id}",
        "details": "${ppg}"
      }
    }
  )}
}
