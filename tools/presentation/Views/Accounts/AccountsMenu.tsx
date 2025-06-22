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

const LoginMenu = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      <li className="dropdown hidden-xs">
          <a href="#" className="btn dropdown-toggle" data-toggle="dropdown">
              <i className="fa fa-user"></i>
          </a>
          <div className="dropdown-menu">
                  <h4>Login</h4>
                  <form id="loginModal">
                      
      <Placeholder name="navbar-activity" rendering={props.rendering} />
          </div>
      </li>
      
    </>
  );
};

export default LoginMenu;
