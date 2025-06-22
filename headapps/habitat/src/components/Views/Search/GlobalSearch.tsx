import {
  ComponentParams,
  ComponentRendering,
  Placeholder,
} from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const GlobalSearch = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3>Global Search</h3>

      <li className="navbar-activity-search dropdown">
        <form action="http://habitat.dev.local/en/Search" className="navbar-form" role="search">
          <div className="form-group">
            <input
              type="text"
              name="query"
              id="searchInputBox"
              placeholder="Enter a text to search for..."
              autocomplete="off"
            />
          </div>
        </form>

        <a
          href="#"
          className="btn navbar-toggle-search"
          data-toggle-className="is-searching"
          data-target="#mainNavbar"
        >
          <span className="glyphicon glyphicon-search"></span>
        </a>

        <div className="dropdown-menu dropdown-menu-wide" id="navbar-activity-search-results">
          <div className="row panel-loading">
            <div className="col-md-12">
              <div className="text-center p-b-1">Searching...</div>
              <div className="text-center">
                <span className="fa fa-spinner fa-2x fa-spin"></span>
              </div>
            </div>
          </div>
          <div className="row panel-results">
            <div className="col-md-12">
              <ul className="media-list results"></ul>
            </div>
          </div>
          <div className="row panel-result-count">
            <div className="col-md-12">
              <small>
                <em className="result-count"></em>
                search results found.
              </small>
            </div>
          </div>
          <div className="row panel-facet-values">
            <div className="col-md-12">
              <ul className="facet-values"></ul>
            </div>
          </div>
          <div className="row">
            <div className="col-md-12">
              <button
                className="btn btn-primary btn-sm pull-right"
                onclick="$('.navbar-activity-search form').submit()"
              >
                Search
              </button>
            </div>
          </div>
        </div>
      </li>
    </>
  );
};

export default GlobalSearch;
