@isTest
public with sharing class KnowledgeServiceTest {
  @TestSetup
  static void makeData() {
    Knowledge__kav kav = new Knowledge__kav(
      UrlName = 'test-url',
      Title = 'Test Url',
      Language = 'en_US'
    );
    insert kav;

    Knowledge__kav kavWithArticleId = [
      SELECT KnowledgeArticleId
      FROM Knowledge__kav
      WHERE id = :kav.id
    ];

    Knowledge__DataCategorySelection tempCat = new Knowledge__DataCategorySelection();
    tempCat.DataCategoryGroupName = 'Category';
    tempCat.DataCategoryName = 'Finding_the_right_license';
    tempCat.ParentId = kav.Id;
    insert tempCat;

    KbManagement.PublishingService.publishArticle(
      kavWithArticleId.KnowledgeArticleId,
      true
    );
  }

  @isTest
  public static void testdataCategoryStructure() {
    Test.startTest();
    List<DataCategory> response = KnowledgeService.getDataCategoryStructure(
      'Category'
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No categories found');
    Assert.areEqual(0, response[0].childCategories.size());
    Assert.isNotNull(response[0].label);
    Assert.isNotNull(response[0].name);
  }

  @isTest
  public static void testGetArticlesPositive() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = KnowledgeService.getArticles(
      'Category',
      'All'
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No articles found');
    Assert.isNotNull(response[0].Title);
  }

  @isTest
  public static void testSearchForArticlesPositive() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = KnowledgeService.searchForArticles(
      'Test',
      'Category',
      'Finding_the_right_license',
      1
    );
    Test.stopTest();
    Assert.isTrue(response.size() > 0, 'No articles found');
  }

  @isTest
  public static void testSearchForArticlesNegative() {
    Test.startTest();
    List<KnowledgeArticleVersion> response = KnowledgeService.searchForArticles(
      'hello',
      'Category',
      'Finding_the_right_license',
      1
    );
    Test.stopTest();
    Assert.areEqual(0, response.size(), 'No articles found');
  }
}
