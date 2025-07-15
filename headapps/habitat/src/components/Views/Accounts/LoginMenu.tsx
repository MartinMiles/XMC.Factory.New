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
      <h3 style={{ color: 'red' }}>Login Menu</h3>

      <li className="dropdown hidden-xs">
        <a href="#" className="btn dropdown-toggle" data-toggle="dropdown">
          <i className="fa fa-user"></i>
        </a>
        <div className="dropdown-menu">
          <h4>Login</h4>
          <form id="loginModal">
            <Placeholder name="navbar-activity" rendering={props.rendering} />
          </form>
        </div>
      </li>
    </>
  );
};

export default LoginMenu;
