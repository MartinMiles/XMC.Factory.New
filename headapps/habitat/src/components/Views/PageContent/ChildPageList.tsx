import { RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';
import { Image, ImageField, Field } from '@sitecore-jss/sitecore-jss-nextjs';
import { useI18n } from 'next-localization';

export function useTranslations() {
  const i18n = useI18n();
  return {
    readLabel: i18n?.t('Read more'),
  };
}

interface ItemProps {
  url: string;
  fields: {
    id: string;
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
  const translations = useTranslations();
  return (
    <>
      <h3>Child Page List</h3>
      <div className="block-grid-md-2 block-grid-sm-1 block-grid-xs-1">
        {props.fields.items.map((item, idx) => (
          <div key={idx} className="block-grid-item">
            <div className="thumbnail">
              <a href={item.url} target="_blank" rel="noopener noreferrer">
                <Image field={item.fields.Image} />
              </a>
              <div className="caption">
                <h3 className="teaser-heading">{item.fields.Title?.value}</h3>
                <RichText field={item.fields.Summary} />
                <a href={item.url} className="btn btn-default">
                  {translations.readLabel}
                </a>
              </div>
            </div>
          </div>
        ))}
      </div>
    </>
  );
};

export default ChildPageList;
