
{
  "env":
  ${jsonencode(
    {
      "region": "${aws_region}",
      "zone": "${zone}",
      "proximity_placement_group": {
        "id": "${ppg_id}",
        "details": "${ppg}"
      }
    }
  )}
}
