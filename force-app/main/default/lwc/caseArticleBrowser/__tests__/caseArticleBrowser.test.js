/**
 * Accessibility tests reside in a different test file in this case
 * because there's an open issue on jest (https://github.com/facebook/jest/issues/8726)
 * because of which fake timers leak into all the tests in the same file,
 * while Axe doen't work when using fake timers.
 **/
import { createElement } from "lwc";
import CaseArticleBrowser from "c/CaseArticleBrowser";
import getSearchResults from "@salesforce/apex/CaseArticleBrowserController.getSearchResults";
import getDataCategoryStructure from "@salesforce/apex/CaseArticleBrowserController.getDataCategoryStructure";

// Realistic data with a list of contacts
const mockGetSearchResults = require("./data/getSearchResults.json");
const mockGetDataCategoryStructure = require("./data/getDataCategoryStructure.json");

// Mock Apex wire adapter
jest.mock(
  "@salesforce/apex/CaseArticleBrowserController.getSearchResults",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn())
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/CaseArticleBrowserController.getDataCategoryStructure",
  () => {
    const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
    return {
      default: createApexTestWireAdapter(jest.fn())
    };
  },
  { virtual: true }
);

describe("c-case-article-browser", () => {
  beforeAll(() => {
    // We use fake timers as setTimeout is used in the JavaScript file.
    jest.useFakeTimers();
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  describe("getSearchResults @wire data", () => {
    it("renders data of one record", async () => {
      const USER_INPUT = "Refer";

      // Create initial element
      const element = createElement("c-case-article-browser", {
        is: CaseArticleBrowser
      });
      element.knowledgeCategory = "Category";
      document.body.appendChild(element);

      // Select input field for simulating user input
      const inputEl = element.shadowRoot.querySelector("lightning-input");
      inputEl.value = USER_INPUT;
      inputEl.dispatchEvent(new CustomEvent("change"));

      // Run all fake timers.
      jest.runAllTimers();

      // Emit data from @wire
      getSearchResults.emit(mockGetSearchResults);

      // Wait for any asynchronous DOM updates
      await flushPromises();

      // Select elements for validation
      const detailEls = element.shadowRoot.querySelector("span");
      expect(detailEls).not.toBeNull();
      expect(detailEls.textContent).toBe(mockGetSearchResults[0].Title);
    });
  });
  describe("getDataCategoryStructure @wire data", () => {
    it("renders the Data Categories at start", async () => {
      // Create initial element
      const element = createElement("c-case-article-browser", {
        is: CaseArticleBrowser
      });
      element.knowledgeCategory = "Category";
      document.body.appendChild(element);

      // Run all fake timers.
      jest.runAllTimers();

      // Emit data from @wire
      getDataCategoryStructure.emit(mockGetDataCategoryStructure);

      // Wait for any asynchronous DOM updates
      await flushPromises();

      // Select elements for validation
      const detailEls = element.shadowRoot.querySelector(".epidemicBox");
      expect(detailEls).not.toBeNull();
      expect(detailEls.textContent).toBe(mockGetDataCategoryStructure[0].label);
    });
  });
});
