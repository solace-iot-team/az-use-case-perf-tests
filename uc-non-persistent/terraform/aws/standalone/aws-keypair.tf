####################################################################################################
# NOTE: The following network resources will only get created if:
# The "public_key_path" variable is NOT left "empty"
####################################################################################################

resource "aws_key_pair" "aws_key" {
  #If a public_key_path is specified, we'll create a new one
  count = var.public_key_path == "" ? 0 : 1

  key_name = var.aws_ssh_key_name
  public_key = file(var.public_key_path)
}