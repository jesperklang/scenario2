public with sharing class CaseArticleBrowserController {
  public class DataCategoryGroup {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
  }

  @AuraEnabled(cacheable=true)
  public static List<DataCategoryGroup> getDataCategoryStructure(
    String dataCategoryGroupName
  ) {
    try {
      List<DataCategoryGroup> categoryGroupsToReturn = new List<DataCategoryGroup>();
      DataCategory[] response = KnowledgeService.getDataCategoryStructure(
        dataCategoryGroupName
      );
      for (DataCategory dataCategory : response) {
        DataCategoryGroup dataCategoryGroup = new DataCategoryGroup();
        dataCategoryGroup.name = dataCategory.name;
        dataCategoryGroup.label = dataCategory.label;
        categoryGroupsToReturn.add(dataCategoryGroup);
      }
      return categoryGroupsToReturn;
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
    if (caseId == null || caseId.getSobjectType() != Schema.Case.SObjectType) {
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
