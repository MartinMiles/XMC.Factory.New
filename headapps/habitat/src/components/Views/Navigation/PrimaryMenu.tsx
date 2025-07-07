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

const PrimaryMenu = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Primary menu</h3>
      <div className="collapse navbar-collapse" id="siteNavbar">
        <ul className="nav navbar-nav">
          <li className=" dropdown">
            <a
              href="http://habitat.dev.local/en/About-Habitat"
              className="dropdown-toggle text-uppercase"
              data-toggle="dropdown"
              role="button"
              aria-haspopup="true"
              aria-expanded="false"
            >
              About Habitat<span className="caret"></span>
            </a>
            <ul className="dropdown-menu">
              <li className="">
                <a href="http://habitat.dev.local/en/About-Habitat/Introduction" target="">
                  Introduction
                </a>
              </li>
              <li className="">
                <a href="http://habitat.dev.local/en/About-Habitat/Getting-Started" target="">
                  Getting Started
                </a>
              </li>
              <li className="">
                <a href="http://helix.sitecore.net" target="_blank">
                  Helix Documentation
                </a>
              </li>
            </ul>
          </li>
          <li className="">
            <a className="text-uppercase" href="http://habitat.dev.local/en/AAA" target="">
              AAA
            </a>
          </li>
          <li className=" dropdown">
            <a
              href="http://habitat.dev.local/en/Modules"
              className="dropdown-toggle text-uppercase"
              data-toggle="dropdown"
              role="button"
              aria-haspopup="true"
              aria-expanded="false"
            >
              Modules<span className="caret"></span>
            </a>
            <ul className="dropdown-menu">
              <li className="">
                <a href="http://habitat.dev.local/en/Modules/Project" target="">
                  Project
                </a>
              </li>
              <li className="">
                <a href="http://habitat.dev.local/en/Modules/Feature" target="">
                  Feature
                </a>
              </li>
              <li className="">
                <a href="http://habitat.dev.local/en/Modules/Foundation" target="">
                  Foundation
                </a>
              </li>
            </ul>
          </li>
          <li className="">
            <a className="text-uppercase" href="http://habitat.dev.local/en/More-Info" target="">
              More Info!
            </a>
          </li>
        </ul>
      </div>
    </>
  );
};

export default PrimaryMenu;
