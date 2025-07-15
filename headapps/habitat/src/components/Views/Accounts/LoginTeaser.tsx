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
      <h3 style={{ color: 'red' }}>Login Teaser</h3>

      <div className="well ">
        <h4>Login Teaser</h4>

        <p>
          This is a login teaser - which is not logged in.
          <br />
          The component will show the user details when logged in.
        </p>

        <form action="/Modules/Feature/Accounts" className="form-signin" method="post">
          <input id="uid" name="uid" type="hidden" value="8aef98dc-dfd6-4711-874f-04774d755d71" />{' '}
          <div className="form-group">
            <input
              className="form-control"
              id="loginEmail"
              name="Email"
              placeholder="Enter your e-mail"
              type="text"
              value=""
            />
          </div>
          <div className="form-group">
            <input
              className="form-control"
              id="loginPassword"
              name="Password"
              placeholder="Enter your password"
              type="password"
            />
          </div>
          <input type="submit" className="btn btn-primary btn-block" value="Login" />
          <a href="/Register" className="btn btn-link btn-block">
            Register
          </a>
          <a
            href="/Login/Forgot-Password"
            className="btn btn-link btn-block"
          >
            Forgot your password?
          </a>
        </form>
      </div>
    </>
  );
};

export default LoginMenu;
