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

const Menuwithlinks = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      
      <nav>
        <ul className="nav nav-service navbar-nav nav-pills">
            <li className="">
              <a href="https://github.com/Sitecore/Habitat/" target="" title="Habitat" className="">
      Habitat        </a>
            </li>
            <li className="">
              <a href="http://helix.sitecore.net" target="" title="Helix" className="">
      Helix        </a>
            </li>
            <li className="divider-left">
              <a href="https://www.sitecore.net" target="_blank" title="Sitecore.net" className="">
      Sitecore.net        </a>
            </li>
        </ul>
      </nav>
      
    </>
  );
};

export default Menuwithlinks;
