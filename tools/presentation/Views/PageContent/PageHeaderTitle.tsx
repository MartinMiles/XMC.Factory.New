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

const PageContentHeaderTitle = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      
      <div className="container m-b-1">
        <h1>
          About Habitat
            <br/>
            <small>
              <p>Habitat sites are demonstration sites for the Sitecore&reg; Experience Platform&trade;.
      </p>
      <p>The sites demonstrate the full set of capabilities and potential of the platform through a number of both technical and business scenarios.</p>
            </small>
        </h1>
      </div>
      
    </>
  );
};

export default PageContentHeaderTitle;
