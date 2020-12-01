
{
  "env":
  ${jsonencode(
    {
      "optimizations": {
        "apply_kernel_optimizations": "${apply_kernel_optimizations}",
        "apply_mellanox_vma": "${apply_mellanox_vma}"
      },
      "region": "${region}",
      "zone": "${zone}",
      "proximity_placement_group": {
        "id": "${ppg_id}",
        "details": "${ppg}"
      }
    }
  )}
}
