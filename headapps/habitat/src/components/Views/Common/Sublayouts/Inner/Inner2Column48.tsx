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

const Inner2Column48 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <div className="row">
        <div className="col-md-4">
          <ul className="nav nav-stacked">
            <li>
              <a
                href="https://github.com/Sitecore/Habitat"
                target="_blank"
                title="GitHub Repository"
              >
                <span>GitHub Repository</span>
              </a>
            </li>
            <li>
              <a href="https://github.com/Sitecore/Habitat/wiki" target="_blank" title="Wiki">
                <span>Wiki</span>
              </a>
            </li>
            <li>
              <a
                href="https://github.com/Sitecore/Habitat/wiki/03-How-can-I-contribute%3F"
                target="_blank"
                title="How to Contribute"
              >
                <span>How to Contribute</span>
              </a>
            </li>
          </ul>
        </div>
        <div className="col-md-8">
          <div className="thumbnail  m-b-1">
            <header className="thumbnail-header">
              <h3>Recommended Reading</h3>
            </header>
            <div>
              <a href="http://www.amazon.com/Agile-Principles-Patterns-Practices-C/dp/0131857258">
                <img
                  src="/-/media/Habitat/Images/Content/Recommended-Reading.png?h=172&amp;mw=500&amp;w=500&amp;hash=7FA2361A398D2C3C1FF9F169CC5A0985"
                  className="img-responsive"
                  alt="Recommended Reading"
                  width="500"
                  height="172"
                  DisableWebEdit="False"
                />
              </a>
            </div>
            <div className="caption">
              <p>
                Many of the principles and thoughts behind the Habitat methodology are described in
                the Books by Robert C. Martin. Recommended reading includes: "Clean Code: A Handbook
                of Agile Software Craftsmanship" and "Agile Principles, Patterns, and Practices in
                C#"
              </p>
              <a
                className="btn btn-default"
                rel="noopener noreferrer"
                href="http://www.amazon.com/Agile-Principles-Patterns-Practices-C/dp/0131857258"
                target="_blank"
              >
                Agile Principles, Patterns and Practises
              </a>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Inner2Column48;
