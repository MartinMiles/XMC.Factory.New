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

const PageTitle = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Page Title</h3>
      <header>
        <h1>
          Find out more
        </h1>
          <div className="lead">
            Want to know more about Helix and Habitat? Here are some interesting links, videos and material for you.
          </div>
      </header>
    </>
  );
};

export default PageTitle;
