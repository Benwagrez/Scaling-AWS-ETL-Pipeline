# ========================= #
# ====== SPN details ====== #
# ========================= #
# Purpose
# Deploy service principal for data visualization tool to use for data sourcing

resource "aws_iam_group" "data_visualization_group" {
    name = "data_visualization_group"
}
 
resource "aws_iam_user" "data_spn" {
    name = "TableauSPN"
}
  
resource "aws_iam_group_membership" "administrators_users" {
    name = "data-visualization-user"
    users = [ aws_iam_user.data_spn.name ]
    group = aws_iam_group.data_visualization_group.name
}