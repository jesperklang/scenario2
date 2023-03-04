import { LightningElement, api, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDataCategoryStructure from "@salesforce/apex/CaseArticleBrowserController.getDataCategoryStructure";
import getArticles from "@salesforce/apex/CaseArticleBrowserController.getArticles";
import getCaseSuggestions from "@salesforce/apex/CaseArticleBrowserController.getCaseSuggestions";
import getSearchResults from "@salesforce/apex/CaseArticleBrowserController.getSearchResults";
import Epidemic_styles from "@salesforce/resourceUrl/Epidemic_styles";

export default class CaseArticleBrowser extends LightningElement {
  @api recordId;
  @api knowledgeCategory;
  searching = false;
  loading = false;
  case;
  caseSubject;
  dataCategories = [];
  selectedCategoryName;
  selectedCategoryLabel;
  articles;
  suggestedArticles = [];
  selectedArticle;
  searchTerm;
  searchResults = [];

  @wire(getDataCategoryStructure, {
    dataCategoryGroupName: "$knowledgeCategory"
  })
  async getInitialDataStructure({ error, data }) {
    this.loading = true;
    if (data) {
      this.dataCategories = JSON.parse(data);
    } else if (error) {
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
    this.loading = false;
  }

  @wire(getCaseSuggestions, {
    caseId: "$recordId",
    dataCategoryGroupName: "$knowledgeCategory"
  })
  async handleSuggestedArticles({ error, data }) {
    this.loading = true;
    if (data) {
      this.suggestedArticles = data;
    } else if (error) {
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
    this.loading = false;
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
    } finally {
      this.loading = false;
    }
  }

  async search() {
    try {
      this.searching = true;
      const data = await getSearchResults({
        searchTerm: this.searchTerm,
        dataCategoryGroupName: this.knowledgeCategory
      });
      this.searchResults = data;
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
    } finally {
      this.searching = false;
    }
  }

  handleKeyUp(event) {
    if (event.keyCode === 13) {
      this.searchTerm = event.target.value;
      if (event.target.value.length >= 3) {
        this.search();
      }
    }
  }

  handleSearchInput(event) {
    if (event.target.value.length >= 3) {
      this.searchTerm = event.target.value;
      this.search();
    } else if (event.target.value.length === 0) {
      this.searchTerm = undefined;
    }
  }

  handleCategoryClick(event) {
    this.selectedCategoryName = event.currentTarget.dataset.category;
    this.selectedCategoryLabel = event.currentTarget.dataset.label;
    this.getCurrentArticles();
  }

  handleArticleClick(event) {
    this.selectedArticle = event.currentTarget.dataset.article;
  }

  clearCategorySelection() {
    this.selectedCategoryName = undefined;
    this.selectedCategoryLabel = undefined;
  }

  connectedCallback() {
    loadStyle(this, Epidemic_styles + "/style.css").then(() => {});
  }

  clearSelectedArticle() {
    this.selectedArticle = undefined;
  }

  clearSearchTerm() {
    this.searchTerm = undefined;
  }

  get isCase() {
    return this.recordId.startsWith("500");
  }

  get showSuggestedArticles() {
    return (
      this.suggestedArticles.length > 0 &&
      (this.searchTerm === undefined || this.searchTerm === null) &&
      (this.selectedCategoryName === undefined ||
        this.selectedCategoryName === null) &&
      (this.selectedArticle === undefined || this.selectedArticle === null)
    );
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

  get hasSearchTerm() {
    return this.searchTerm !== undefined && this.searchTerm !== null;
  }

  get hasSearchResults() {
    return (
      this.searchResults !== undefined &&
      this.searchResults !== null &&
      this.searchResults.length > 0
    );
  }
}
