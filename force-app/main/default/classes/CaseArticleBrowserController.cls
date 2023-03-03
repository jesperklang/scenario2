public with sharing class CaseArticleBrowserController {
  @AuraEnabled(cacheable=true)
  public static String getDataCategoryStructure(String dataCategoryGroupName) {
    try {
      return KnowledgeService.getDataCategoryStructure(dataCategoryGroupName);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<KnowledgeArticleVersion> getArticles(
    String dataCategoryGroupName,
    String dataCategoryName
  ) {
    try {
      return KnowledgeService.getArticles(
        dataCategoryGroupName,
        dataCategoryName
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=false)
  public static List<KnowledgeArticleVersion> getCaseSuggestionData(
    String dataCategoryGroupName
  ) {
    try {
      System.debug(dataCategoryGroupName);
      return KnowledgeService.getCaseSuggestionData(dataCategoryGroupName);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}