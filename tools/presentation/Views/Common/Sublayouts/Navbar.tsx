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

const MainNavigation = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      <nav className="navbar navbar-default navbar-static" id="mainNavbar">
        <div className="container">
          <div className="navbar-left">
            <button type="button" className="navbar-toggle collapsed" data-toggle="collapse" data-target="#siteNavbar" aria-expanded="false">
              <span className="sr-only">Toggle navigation</span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
      
            
      <Placeholder name="navbar-left" rendering={props.rendering} />
      
          </div>
          <div className="navbar-center">
            
          </div>
          <div className="navbar-right">
            
      <Placeholder name="navbar-right" rendering={props.rendering} />
      
          </div>
        </div>
      </nav>
      
    </>
  );
};

export default MainNavigation;
