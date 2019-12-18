unit hcTreeViewUtils;

interface

uses
  ComCtrls;

procedure ToggleNodeSiblings(Node :TTreeNode; Select :Boolean);
procedure ToggleNodeChildren(Node :TTreeNode; Select :Boolean);
procedure ToggleNode(Node :TTreeNode; Select :Boolean);

implementation

uses
  hcDeploymentRegion, hcDeploymentStudio;

procedure ToggleNodeSiblings(Node :TTreeNode; Select :Boolean);
var
  aNode :TTreeNode;
begin
  aNode := Node.getNextSibling;
  while aNode <> nil do
  begin
    ToggleNode(aNode,Select);
    aNode := aNode.getNextSibling;
  end;
end;

procedure ToggleNodeChildren(Node :TTreeNode; Select :Boolean);
var
  aNode :TTreeNode;
begin
  aNode := Node.getFirstChild;
  while aNode <> nil do
  begin
    ToggleNode(aNode,Select);
    aNode :=  Node.GetNextChild(aNode);
  end;
end;

procedure ToggleNode(Node :TTreeNode; Select :Boolean);
begin
  //toggle selected studio node
  if (TObject(Node.Data) is ThcDeploymentStudio) then
  begin
    ThcDeploymentStudio(Node.Data).UserSelected.AsBoolean := Select;
    if Select then
      Node.StateIndex := 1  //first stateindex image
    else
      Node.StateIndex := 0;
  end
  else
  //toggle all studios underneath this region
  if (TObject(Node.Data) is ThcDeploymentRegion) then
  begin
    if Select then
      Node.StateIndex := 1  //first stateindex image
    else
      Node.StateIndex := 0;
    ToggleNodeChildren(Node,Select);
  end
  else
  if (Node.Data = nil)  and (Node = Node.TreeView.TopItem) then
  begin
    if Select then
      Node.StateIndex := 1  //first stateindex image
    else
      Node.StateIndex := 0;
    ToggleNodeChildren(Node,Select);
  end;
end;


end.
