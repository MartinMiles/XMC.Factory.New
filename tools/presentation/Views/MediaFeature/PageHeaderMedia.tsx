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

const PageHeaderwithMedia = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      <header className="page-header bg-dark" >
        
      <Placeholder name="page-header" rendering={props.rendering} />
      
      </header>
      
      
    </>
  );
};

export default PageHeaderwithMedia;
