import { LinkFieldValue, Field } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ItemProps {
  fields: {
    Link: { value: LinkFieldValue };
    NavigationTitle: Field<string>;
    ShowInNavigation: Field<boolean>;
    ShowChildren: Field<boolean>;
    DividerBefore: Field<boolean>;
  };
}
interface MenuWithLinksProps {
  params: { [key: string]: string };
  fields: {
    items: ItemProps[];
  };
}

const Menuwithlinks = (props: MenuWithLinksProps): JSX.Element => {
  return (
    <>
      <h3>Menu with links</h3>
      <nav>
        <ul className="nav nav-service navbar-nav nav-pills">
          {props.fields.items.map((item, idx) => (
            <li key={idx} className={item.fields.DividerBefore.value ? 'divider-left' : ''}>
              <a
                href={item.fields.Link.value.href}
                target={item.fields.Link.value.target}
                title={item.fields.Link.value.title}
                className={item.fields.Link.value.class}
              >
                {item.fields.NavigationTitle.value}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </>
  );
};

export default Menuwithlinks;
