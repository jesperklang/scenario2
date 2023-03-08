public with sharing class KnowledgeService {
  public static DataCategory[] getDataCategoryStructure(
    String dataCategoryGroupName
  ) {
    //Creating a list of pair objects to use as a parameter for the describe call
    List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
    p.setSobject('KnowledgeArticleVersion');
    p.setDataCategoryGroupName(dataCategoryGroupName);
    pairs.add(p);

    List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(
      pairs,
      false
    );

    //Getting data from the result
    DataCategory[] toReturn = describeCategoryStructureResult[0]
      .getTopCategories();
    return toReturn[0].childcategories;
  }

  public static List<KnowledgeArticleVersion> getArticles(
    String dataCategoryGroupName,
    String dataCategoryName
  ) {
    String queryString =
      'SELECT Title, LastPublishedDate, ArticleCaseAttachCount FROM KnowledgeArticleVersion WHERE PublishStatus=\'online\' WITH DATA CATEGORY ' +
      dataCategoryGroupName +
      '__c BELOW ' +
      dataCategoryName +
      '__c';
    List<KnowledgeArticleVersion> articles = Database.query(queryString);
    return articles;
  }

  public static List<KnowledgeArticleVersion> searchForArticles(
    String query,
    String dataCategoryGroup,
    String dataCategory,
    Integer recordLimit
  ) {
    String queryString =
      'SELECT Title, LastPublishedDate, ArticleCaseAttachCount FROM KnowledgeArticleVersion WHERE PublishStatus=\'online\' AND Title LIKE \'%' +
      query +
      '%\' WITH DATA CATEGORY ' +
      dataCategoryGroup +
      '__c BELOW ' +
      dataCategory +
      '__c LIMIT ' +
      recordLimit;
    List<KnowledgeArticleVersion> articles = Database.query(queryString);
    return articles;
    //TODO: Query the Promoted Search Terms on articles
  }
}
