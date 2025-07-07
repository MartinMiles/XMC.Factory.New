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
      <div className="login-body">
        <div className="form-group">
          <label className="control-label" for="Email">
            E-mail
          </label>
          <input
            className="form-control"
            id="popupLoginEmail"
            name="Email"
            placeholder="Enter your e-mail"
            type="text"
            value=""
          />
        </div>
        <div className="form-group">
          <label className="control-label" for="Password">
            Password
          </label>
          <input
            className="form-control"
            id="popupLoginPassword"
            name="Password"
            placeholder="Enter your password"
            type="password"
          />
        </div>
        <button type="button" className="btn btn-block btn-primary" onclick="login('loginModal')">
          Login
        </button>
        <a
          className="btn btn-block btn-default"
          href="http://habitat.dev.local/en/Login/Forgot-Password"
        >
          Forgot your password?
        </a>
        <a className="btn btn-block btn-default" href="http://habitat.dev.local/en/Register">
          Register
        </a>
      </div>
    </>
  );
};

export default LoginMenu;
