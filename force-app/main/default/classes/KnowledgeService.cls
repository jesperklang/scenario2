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
    Search.KnowledgeSuggestionFilter filters = new Search.KnowledgeSuggestionFilter();
    filters.setLanguage('en_US');
    filters.setPublishStatus('Online');
    filters.addDataCategory(dataCategoryGroup, dataCategory);

    Search.SuggestionOption options = new Search.SuggestionOption();
    options.setFilter(filters);
    options.setLimit(recordLimit);

    Search.SuggestionResults suggestionResults = Search.suggest(
      query,
      'KnowledgeArticleVersion',
      options
    );
    List<KnowledgeArticleVersion> articles = new List<KnowledgeArticleVersion>();
    for (
      Search.SuggestionResult searchResult : suggestionResults.getSuggestionResults()
    ) {
      KnowledgeArticleVersion article = (KnowledgeArticleVersion) searchResult.getSObject();
      articles.add(article);
    }
    return articles;
  }
}
