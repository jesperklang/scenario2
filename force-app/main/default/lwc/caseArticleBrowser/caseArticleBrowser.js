import { LightningElement, api, wire, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDataCategoryStructure from "@salesforce/apex/CaseArticleBrowserController.getDataCategoryStructure";
import getArticles from "@salesforce/apex/CaseArticleBrowserController.getArticles";
import getCaseSuggestionData from "@salesforce/apex/CaseArticleBrowserController.getCaseSuggestionData";
import Epidemic_styles from "@salesforce/resourceUrl/Epidemic_styles";

const FIELDS = ["Case.Subject"];

export default class CaseArticleBrowser extends LightningElement {
  @api recordId;
  @api knowledgeCategory;
  loading = false;
  error; //TODO: handle errors
  case;
  caseSubject;
  dataCategories = [];
  selectedCategoryName;
  articles;
  @track suggestedArticles = [];
  selectedArticle;

  @wire(getDataCategoryStructure, {
    dataCategoryGroupName: "$knowledgeCategory"
  })
  async getInitialDataStructure({ error, data }) {
    this.loading = true;
    if (data) {
      this.dataCategories = JSON.parse(data);
      // await this.getCurrentArticles();
    } else if (error) {
      this.error = error;
      console.log(error);
    }
    this.loading = false;
  }

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ error, data }) {
    if (error) {
      if (!this.isCase) {
        this.suggestedArticles = [];
        return;
      }
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading contact",
          message,
          variant: "error"
        })
      );
    } else if (data) {
      this.case = data;
      this.caseSubject = this.case.fields.Subject.value;
      this.getSuggestedArticlesData();
    }
  }

  async getCurrentArticles() {
    try {
      this.loading = true;
      const data = await getArticles({
        dataCategoryGroupName: this.knowledgeCategory,
        dataCategoryName: this.selectedCategoryName
      });
      this.articles = data;
    } catch (error) {
      console.log(error);
      this.error = error;
    } finally {
      this.loading = false;
    }
  }

  async getSuggestedArticlesData() {
    try {
      this.loading = true;
      const data = await getCaseSuggestionData({
        dataCategoryGroupName: this.knowledgeCategory
      });
      console.log(data);
      const subjectWords = this.caseSubject.split(" ").filter(Boolean);
      let suggestedArticles = [];
      data.forEach(element => {
        const articleWords = element.Title.split(" ").filter(Boolean);
        const matchedWords = articleWords.filter((word) => subjectWords.includes(word));
        if (matchedWords.length > 0) {
          suggestedArticles.push(element);
        }
      });
      this.suggestedArticles = suggestedArticles;
      console.log({suggestedArticles: this.suggestedArticles});
    } catch (error) {
      console.log(error);
      this.error = error;
    } finally {
      this.loading = false;
    }
  }

  handleCategoryClick(event) {
    this.selectedCategoryName = event.currentTarget.dataset.category;
    this.getCurrentArticles();
  }

  handleArticleClick(event) {
    this.selectedArticle = event.currentTarget.dataset.article;
  }

  clearCategorySelection() {
    this.selectedCategoryName = undefined;
  }

  comboOptions = [
    { label: "Option 1", value: "1" },
    { label: "Option 2", value: "2" },
    { label: "Option 3", value: "3" }
  ];

  renderedCallback() {
    loadStyle(this, Epidemic_styles + "/style.css").then(() => {});
  }

  clearSelectedArticle() {
    this.selectedArticle = undefined;
  }

  get isCase() {
    return this.recordId.startsWith("500");
  }

  get showSuggestedArticles() {
    return this.suggestedArticles.length > 0 && (this.selectedCategoryName === undefined ||
    this.selectedCategoryName === null) && (this.selectedArticle === undefined || this.selectedArticle === null);
  }

  get categoryIsSelected() {
    return (
      this.selectedCategoryName !== undefined &&
      this.selectedCategoryName !== null
    );
  }

  get articleIsSelected() {
    return this.selectedArticle !== undefined && this.selectedArticle !== null;
  }
}