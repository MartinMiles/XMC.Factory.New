import { RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';
import {
  Image,
  // LinkField,
  // RichText,
  ImageField,
  Field,
  // LinkField,
} from '@sitecore-jss/sitecore-jss-nextjs';

// interface ComponentProps {
//   rendering: ComponentRendering & { params: ComponentParams };
//   params: ComponentParams;
// }

interface ItemProps {
  fields: {
    id: string;
    url: string;
    Title: Field<string>;
    Summary: { value: string };
    Image: { value: ImageField };
  };
}
interface PageFieldsProps {
  params: { [key: string]: string };
  fields: {
    items: ItemProps[];
  };
}

const ChildPageList = (props: PageFieldsProps): JSX.Element => {
  return (
    <>
      <h3>Child Page List</h3>
      <div className="block-grid-md-2 block-grid-sm-1 block-grid-xs-1">
        {props.fields.items.map((item, idx) => (
          <div key={idx} className="block-grid-item">
            <div>
              <div className="thumbnail">
                <a href={item.fields.url}>
                  <Image field={item.fields.Image} />
                </a>
                <div className="caption">
                  <h3 className="teaser-heading">{item.fields.Title?.value}</h3>

                  <RichText field={item.fields.Summary} />

                  <a href={item.fields.url} className="btn btn-default">
                    Read more
                  </a>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </>
  );
};

export default ChildPageList;
