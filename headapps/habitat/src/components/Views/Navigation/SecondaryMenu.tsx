import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const SecondaryMenu = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Secondary menu</h3>

      <h4>
        <a href="/About-Habitat" target="">
          About Habitat
        </a>
      </h4>
      <div className="sidebar sidebar-static">
        <ul className="nav nav-pills nav-stacked">
          <li className="active open">
            <a href="/About-Habitat/Introduction" target="">
              Introduction
            </a>

            <ul className="nav nav-pills nav-stacked">
              <li className="">
                <a href="/About-Habitat/Introduction/Modular-Architecture" target="">
                  Modular Architecture
                </a>
              </li>
              <li className="">
                <a href="/About-Habitat/Introduction/Dependencies-and-Layers" target="">
                  Dependencies and Layers
                </a>
              </li>
            </ul>
          </li>
          <li className="">
            <a href="/About-Habitat/Getting-Started" target="">
              Getting Started
            </a>
          </li>
          <li className="">
            <a href="http://helix.sitecore.net" target="_blank">
              Helix Documentation
            </a>
          </li>
        </ul>
      </div>
    </>
  );
};

export default SecondaryMenu;
