import { LightningElement, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class CaseArticleBrowserBody extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api articleId;
  articleInfo = {
    title: "",
    body: "",
    articleId: ""
  };

  goBack() {
    this.dispatchEvent(new CustomEvent("back"));
  }

  handleLoad(event) {
    this.articleInfo.title =
      event.detail.records[this.articleId].fields.Title.value;
    this.articleInfo.body =
      event.detail.records[this.articleId].fields.Content__c.value;
    //this.articleInfo.articleId =
      //event.detail.records[this.articleId].fields.KnowledgeArticleId.value;
  }

  handleEmailButton() {
    const pageRef = {
      type: "standard__quickAction",
      attributes: {
        apiName: "Case.SendEmail"
      },
      state: {
        recordId: this.recordId,
        defaultFieldValues: encodeDefaultFieldValues({
          HtmlBody: this.articleInfo.body,
          Subject: this.articleInfo.title
        })
      }
    };
    this[NavigationMixin.Navigate](pageRef);
    this.attachArticleToCase();
  }

  attachArticleToCase() {
    const record = {
      apiName: "CaseArticle",
      fields: {
        CaseId: this.recordId,
        KnowledgeArticleVersionId: this.articleId
      }
    };
    console.log(record);
    try {
      createRecord(record);
    } catch (error) {
      console.log(error);
    }
  }

  get deactivateEmailButton() {
    return !this.recordId.startsWith("500");
  }
}