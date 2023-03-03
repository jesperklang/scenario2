public class KnowledgeCategoryPicker extends VisualEditor.DynamicPickList {
  public VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();

  public KnowledgeCategoryPicker() {
    List<String> objType = new List<String>{ 'KnowledgeArticleVersion' };
    List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(
      objType
    );
    for (
      Schema.DescribeDataCategoryGroupResult groupResult : describeCategoryResult
    ) {
      myValues.addRow(
        new VisualEditor.DataRow(groupResult.getLabel(), groupResult.getName())
      );
    }
  }

  public override VisualEditor.DataRow getDefaultValue() {
    return myValues.get(0);
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    return myValues;
  }
}