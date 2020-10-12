
{
  "env":
  ${jsonencode(
    {
      "proximity_placement_group": {
        "id": "${ppg_id}",
        "details": "${ppg}"
      }
    }
  )}
}
