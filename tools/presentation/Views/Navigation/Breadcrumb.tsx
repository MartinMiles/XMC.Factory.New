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

const Breadcrumb = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      <div className="container">
        <ol className="breadcrumb">
            <li className="">
              <a href="http://habitat.dev.local/en">Home</a>
            </li>
            <li className="active">
              <a href="http://habitat.dev.local/en/About-Habitat">About Habitat</a>
            </li>
        </ol>
      </div>
      
    </>
  );
};

export default Breadcrumb;
