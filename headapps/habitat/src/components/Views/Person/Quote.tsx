import { ImageField, Text, Image } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  Name: { value: string };
  Title: { value: string };
  Quote: { value: string };
  Picture: { value: ImageField };
}

type QuoteProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const Quote = (props: QuoteProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Quote</h3>
      <blockquote className="blockquote-center ">
        <header>
          <Image field={props.fields.Picture} />
          <p>
            <Text field={props.fields.Name} />
          </p>
          <p>
            <Text field={props.fields.Title} />
          </p>
        </header>
        <p>
          <Text field={props.fields.Quote} />
        </p>
      </blockquote>
    </>
  );
};

export default Quote;
