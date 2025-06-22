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
      
      <div className="m-t-1">
                  <form action="/identity/externallogin?authenticationType=Facebook&amp;ReturnUrl=%2fidentity%2fexternallogincallback%3fReturnUrl%3d%26sc_site%3dhabitat%26authenticationSource%3dDefault&amp;sc_site=habitat" method="post" className="form-signin">
                      <button className="btn btn-block btn-secondary" type="submit">
                              <i className="fa fa-facebook"></i>
                          <span>
                              Sign in with Facebook
                          </span>
                      </button>
                  </form>
      </div>
      
    </>
  );
};

export default LoginMenu;
