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

const Logo = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      
      
      <a className="navbar-brand " href="http://habitat.dev.local/en">
        <span className="logo">
          <img src="/-/media/Habitat/Images/Logo/Habitat-New.png?h=50&amp;mh=50&amp;w=226&amp;hash=6ABE1FE87C08A5C1D7C2DB2E1DBBEDFF" alt="Habitat Logo" width="226" height="50" DisableWebEdit="False" />
        </span>
      </a>
      
      
    </>
  );
};

export default Logo;
