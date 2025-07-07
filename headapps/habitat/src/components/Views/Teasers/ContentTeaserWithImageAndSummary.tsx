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

const ContentTeaserWithImageAndSummary = (props: ComponentProps): JSX.Element => {
  return (
    <>
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
            />
          </a>
        </div>
        <div className="caption">
          <p>
            Many of the principles and thoughts behind the Habitat methodology are described in the Books by Robert C. Martin. Recommended reading includes: "Clean Code: A Handbook of Agile Software Craftsmanship" and "Agile Principles, Patterns, and Practices in C#"
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
    </>
  );
};

export default ContentTeaserWithImageAndSummary;
