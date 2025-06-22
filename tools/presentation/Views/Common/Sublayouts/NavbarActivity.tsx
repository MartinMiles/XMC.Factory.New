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

const MainNavigationActivity = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      <div className="navbar-activity">
        <ul className="nav navbar-nav">
          
      <Placeholder name="navbar-activity" rendering={props.rendering} />
      
        </ul>
      </div>
      
    </>
  );
};

export default MainNavigationActivity;
