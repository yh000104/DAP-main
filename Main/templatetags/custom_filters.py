from django import template
import codecs

register = template.Library()


@register.filter
def decode_text(text, encoding):
    try:
        decoded_text = codecs.decode(text, encoding)
        return decoded_text
    except UnicodeDecodeError:
        return text
