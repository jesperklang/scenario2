@isTest
public with sharing class CaseArticleBrowserControllerTest {
  @TestSetup
  static void makeData() {
    Knowledge__kav kav = new Knowledge__kav();
    kav.UrlName = 'test-url';
    kav.Title = 'Test akv';
    kav.Language = 'en_US';
    insert kav;

    Id kaId = [
      SELECT KnowledgeArticleId
      FROM Knowledge__kav
      WHERE id = :kav.id
    ]
    .KnowledgeArticleId;

    Knowledge__DataCategorySelection tempCat = new Knowledge__DataCategorySelection();
    tempCat.DataCategoryGroupName = 'Category'; // key line
    tempCat.DataCategoryName = 'Finding_the_right_license'; //m.Category_Path__c;
    tempCat.ParentId = kav.Id;
    insert tempCat;

    KbManagement.PublishingService.publishArticle(kaId, true);
  }

  @isTest
  public static void testGetDataCategoryStructure() {
    Test.startTest();
    String stringResponse = CaseArticleBrowserController.getDataCategoryStructure(
      'Category'
    );
    List<DataCategory> response = KnowledgeService.getDataCategoryStructure(
      'Category'
    );
    String serializedResponse = JSON.serialize(response);
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No categories found');
    Assert.areEqual(stringResponse, serializedResponse);
  }

  @isTest
  public static void testGetDataCategoryStructureNegative() {
    String exceptionType;
    Test.startTest();
    try {
      String stringResponse = CaseArticleBrowserController.getDataCategoryStructure(
        'WrongCategory'
      );
    } catch (Exception e) {
      exceptionType = e.getTypeName();
    }
    Test.stopTest();
    Assert.areEqual(
      'System.AuraHandledException',
      exceptionType,
      'Wrong exception type'
    );
  }

  @isTest
  public static void testGetArticlesPositive() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getArticles(
      'Category',
      'All'
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No articles found');
    Assert.isNotNull(response[0].Title);
  }

  @isTest
  public static void testGetArticlesNegative() {
    String exceptionType;
    Test.startTest();
    try {
      List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getArticles(
        'WrongCategory',
        'All'
      );
    } catch (Exception e) {
      exceptionType = e.getTypeName();
    }
    Test.stopTest();
    Assert.areEqual(
      'System.AuraHandledException',
      exceptionType,
      'Wrong exception type'
    );
  }

  @isTest
  public static void testGetCaseSuggestionsPositive() {
    Case c = new Case(
      Origin = 'Phone',
      Subject = 'test',
      Language__c = 'en',
      Customer_Type__c = 'Free'
    );
    insert c;
    Test.startTest();
    List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getCaseSuggestions(
      c.Id,
      'Category'
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No articles found');
  }

  @isTest
  public static void testGetCaseSuggestionsNegative() {
    List<KnowledgeArticleVersion> response;
    Test.startTest();
    response = CaseArticleBrowserController.getCaseSuggestions(
      null,
      'Category'
    );
    Test.stopTest();
    Assert.isNull(
      response,
      'There were responses even though the caseId were set to null'
    );
  }

  @isTest
  public static void testGetCaseSuggestionsNegativeCategory() {
    String exceptionType;
    Case c = new Case(
      Origin = 'Phone',
      Subject = 'test',
      Language__c = 'en',
      Customer_Type__c = 'Free'
    );
    insert c;
    Test.startTest();
    try {
      List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getCaseSuggestions(
        c.Id,
        'SomeCategory'
      );
    } catch (Exception e) {
      exceptionType = e.getTypeName();
    }
    Test.stopTest();
    Assert.areEqual(
      'System.AuraHandledException',
      exceptionType,
      'Wrong exception type'
    );
  }

  @isTest
  public static void testGetSearchResultsPositive() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getSearchResults(
      'test',
      'Category'
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No articles found');
  }

  @isTest
  public static void testGetSearchResultsNegative() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getSearchResults(
      'this will not be found',
      'Category'
    );
    Test.stopTest();
    Assert.areEqual(0, response.size(), 'No articles found');
  }

  @isTest
  public static void testGetSearchResultsNegativeCategory() {
    String exceptionType;
    Test.startTest();
    try {
      List<KnowledgeArticleVersion> response = CaseArticleBrowserController.getSearchResults(
        'this will not be found',
        'WrongCategory'
      );
    } catch (Exception e) {
      exceptionType = e.getTypeName();
    }
    Test.stopTest();
    Assert.areEqual(
      'System.AuraHandledException',
      exceptionType,
      'Wrong exception type'
    );
  }
}
