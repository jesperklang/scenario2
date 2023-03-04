import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class CaseArticleBrowserBody extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api articleId;
  articleInfo = {
    title: undefined,
    body: undefined,
    article: undefined
  };

  goBack() {
    this.dispatchEvent(new CustomEvent("back"));
  }

  handleLoad(event) {
    try {
      this.articleInfo.title =
        event.detail.records[this.articleId].fields.Title.value;
      this.articleInfo.body =
        event.detail.records[this.articleId].fields.Content__c.value;
      this.articleInfo.article =
        event.detail.records[this.articleId].fields.KnowledgeArticleId.value;
    } catch {
      console.log("");
    }
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
  }

  async attachArticleToCase() {
    const record = {
      apiName: "CaseArticle",
      fields: {
        CaseId: this.recordId,
        KnowledgeArticleId: this.articleInfo.article
      }
    };
    try {
      await createRecord(record);
      const event = new ShowToastEvent({
        title: "Success!",
        message: "Thanks for showing the article some love! ❤️",
        variant: "success"
      });
      this.dispatchEvent(event);
    } catch (error) {
      let errorMessage = "Unknown error";
      if (Array.isArray(error.body)) {
        errorMessage = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        errorMessage = error.body.message;
      }
      const event = new ShowToastEvent({
        title: "Something happened!",
        message: errorMessage,
        variant: "error"
      });
      this.dispatchEvent(event);
      console.log(error);
    }
  }

  get deactivateEmailButton() {
    return (
      this.recordId === null ||
      this.recordId === undefined ||
      !this.recordId.startsWith("500")
    );
  }
}
