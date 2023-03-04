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

  @AuraEnabled(cacheable=true)
  public static List<KnowledgeArticleVersion> getCaseSuggestions(
    Id caseId,
    String dataCategoryGroupName
  ) {
    if (caseId.getSobjectType() != Schema.Case.SObjectType) {
      return null;
    }
    try {
      String caseSubject = [SELECT Subject FROM Case WHERE Id = :caseId LIMIT 1]
      .Subject;
      return KnowledgeService.searchForArticles(
        caseSubject,
        dataCategoryGroupName,
        'All',
        5
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<KnowledgeArticleVersion> getSearchResults(
    String searchTerm,
    String dataCategoryGroupName
  ) {
    try {
      return KnowledgeService.searchForArticles(
        searchTerm,
        dataCategoryGroupName,
        'All',
        9999
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
