import 'dart:convert';
import 'package:flutter/material.dart';

/// Utility class for parsing and rendering Quill Delta JSON content.
///
/// Quill Delta is a JSON-based format for representing rich text content.
/// This parser converts Delta operations into Flutter widgets.
///
/// Example Delta JSON:
/// ```json
/// [
///   {"insert": "Hello ", "attributes": {"bold": true}},
///   {"insert": "World\n"}
/// ]
/// ```
class QuillDeltaParser {
  /// Parse Quill Delta JSON string into a list of operations.
  /// Returns null if parsing fails.
  static List<Map<String, dynamic>>? parseDelta(String content) {
    if (content.isEmpty) return null;

    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Not valid JSON, content is plain text
    }
    return null;
  }

  /// Check if content is Quill Delta JSON format.
  static bool isQuillDelta(String content) {
    if (content.isEmpty) return false;
    try {
      final decoded = jsonDecode(content);
      if (decoded is List && decoded.isNotEmpty) {
        // Check if it has the Delta structure (insert key)
        return decoded.first is Map && decoded.first.containsKey('insert');
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Extract plain text from Quill Delta JSON.
  /// Falls back to returning the original content if not valid Delta.
  static String extractPlainText(String content) {
    final delta = parseDelta(content);
    if (delta == null) return content;

    final buffer = StringBuffer();
    for (final op in delta) {
      final insert = op['insert'];
      if (insert is String) {
        buffer.write(insert);
      } else if (insert is Map) {
        // Handle embeds (images, etc.) - add placeholder or skip
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Calculate word count from Quill Delta content.
  static int getWordCount(String content) {
    final plainText = extractPlainText(content);
    if (plainText.isEmpty) return 0;
    return plainText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Calculate estimated read time in seconds.
  /// Uses average reading speed of 200 words per minute.
  static int calculateReadTime(String content) {
    final wordCount = getWordCount(content);
    if (wordCount == 0) return 0;
    // 200 words per minute = 60 seconds / 200 words
    return ((wordCount / 200) * 60).ceil();
  }

  /// Build a list of TextSpan widgets from Quill Delta JSON.
  /// This is useful for rendering inline formatted text.
  static List<InlineSpan> buildTextSpans(
    String content, {
    TextStyle? baseStyle,
    Color? linkColor,
  }) {
    final delta = parseDelta(content);
    if (delta == null) {
      // Plain text fallback
      return [TextSpan(text: content, style: baseStyle)];
    }

    final spans = <InlineSpan>[];

    for (final op in delta) {
      final insert = op['insert'];
      final attributes = op['attributes'] as Map<String, dynamic>?;

      if (insert is String) {
        final style = _buildTextStyle(
          attributes,
          baseStyle: baseStyle,
          linkColor: linkColor,
        );
        spans.add(TextSpan(text: insert, style: style));
      } else if (insert is Map) {
        // Handle embeds (images, etc.)
        // For now, skip embeds in TextSpan rendering
      }
    }

    return spans;
  }

  /// Build Flutter widgets from Quill Delta JSON.
  /// This renders the full document with blocks, lists, etc.
  static List<Widget> buildWidgets(
    String content, {
    TextStyle? baseStyle,
    Color? linkColor,
    double? imageMaxWidth,
    EdgeInsets? paragraphPadding,
    EdgeInsets? listItemPadding,
    EdgeInsets? blockquotePadding,
    Color? blockquoteColor,
    double blockquoteBorderWidth = 4.0,
  }) {
    final delta = parseDelta(content);
    if (delta == null) {
      // Plain text fallback - split by newlines into paragraphs
      return content.split('\n').where((p) => p.isNotEmpty).map((p) {
        return Padding(
          padding: paragraphPadding ?? const EdgeInsets.symmetric(vertical: 8),
          child: Text(p, style: baseStyle),
        );
      }).toList();
    }

    final widgets = <Widget>[];
    final currentLine = <InlineSpan>[];
    Map<String, dynamic>? lineAttributes;

    void flushLine() {
      if (currentLine.isEmpty) return;

      Widget lineWidget = RichText(
        text: TextSpan(children: List.from(currentLine), style: baseStyle),
      );

      // Apply line-level formatting
      if (lineAttributes != null) {
        // Headers
        final header = lineAttributes!['header'] as int?;
        if (header != null && header >= 1 && header <= 6) {
          lineWidget = _buildHeader(currentLine, header, baseStyle);
        }

        // Lists
        final list = lineAttributes!['list'] as String?;
        if (list != null) {
          lineWidget = _buildListItem(
            currentLine,
            list == 'ordered',
            baseStyle,
            listItemPadding,
          );
        }

        // Blockquote
        final blockquote = lineAttributes!['blockquote'] as bool?;
        if (blockquote == true) {
          lineWidget = _buildBlockquote(
            currentLine,
            baseStyle,
            blockquotePadding,
            blockquoteColor,
            blockquoteBorderWidth,
          );
        }

        // Code block
        final codeBlock = lineAttributes!['code-block'] as bool?;
        if (codeBlock == true) {
          lineWidget = _buildCodeBlock(currentLine, baseStyle);
        }

        // Text alignment
        final align = lineAttributes!['align'] as String?;
        if (align != null) {
          lineWidget = Align(
            alignment: _getAlignment(align),
            child: lineWidget,
          );
        }
      }

      widgets.add(Padding(
        padding: paragraphPadding ?? const EdgeInsets.symmetric(vertical: 4),
        child: lineWidget,
      ));

      currentLine.clear();
      lineAttributes = null;
    }

    for (final op in delta) {
      final insert = op['insert'];
      final attributes = op['attributes'] as Map<String, dynamic>?;

      if (insert is String) {
        // Check for newlines
        if (insert.contains('\n')) {
          final parts = insert.split('\n');
          for (int i = 0; i < parts.length; i++) {
            if (parts[i].isNotEmpty) {
              final style = _buildTextStyle(
                attributes,
                baseStyle: baseStyle,
                linkColor: linkColor,
              );
              currentLine.add(TextSpan(text: parts[i], style: style));
            }
            if (i < parts.length - 1) {
              // Line break - check for line-level attributes
              lineAttributes = attributes;
              flushLine();
            }
          }
        } else {
          final style = _buildTextStyle(
            attributes,
            baseStyle: baseStyle,
            linkColor: linkColor,
          );
          currentLine.add(TextSpan(text: insert, style: style));
        }
      } else if (insert is Map) {
        // Handle embeds
        final image = insert['image'] as String?;
        if (image != null) {
          flushLine();
          widgets.add(_buildImage(image, imageMaxWidth));
        }
      }
    }

    // Flush remaining content
    if (currentLine.isNotEmpty) {
      flushLine();
    }

    return widgets;
  }

  static TextStyle _buildTextStyle(
    Map<String, dynamic>? attributes, {
    TextStyle? baseStyle,
    Color? linkColor,
  }) {
    TextStyle style = baseStyle ?? const TextStyle();

    if (attributes == null) return style;

    // Bold
    if (attributes['bold'] == true) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }

    // Italic
    if (attributes['italic'] == true) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }

    // Underline
    if (attributes['underline'] == true) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }

    // Strikethrough
    if (attributes['strike'] == true) {
      style = style.copyWith(decoration: TextDecoration.lineThrough);
    }

    // Link
    if (attributes['link'] != null) {
      style = style.copyWith(
        color: linkColor ?? Colors.blue,
        decoration: TextDecoration.underline,
      );
    }

    // Code (inline)
    if (attributes['code'] == true) {
      style = style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
      );
    }

    return style;
  }

  static Widget _buildHeader(
    List<InlineSpan> spans,
    int level,
    TextStyle? baseStyle,
  ) {
    final fontSizes = {
      1: 32.0,
      2: 28.0,
      3: 24.0,
      4: 20.0,
      5: 18.0,
      6: 16.0,
    };

    final headerStyle = (baseStyle ?? const TextStyle()).copyWith(
      fontSize: fontSizes[level] ?? 16.0,
      fontWeight: FontWeight.bold,
    );

    return RichText(
      text: TextSpan(children: spans, style: headerStyle),
    );
  }

  static Widget _buildListItem(
    List<InlineSpan> spans,
    bool ordered,
    TextStyle? baseStyle,
    EdgeInsets? padding,
  ) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              ordered ? '1.' : '\u2022',
              style: baseStyle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(children: spans, style: baseStyle),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBlockquote(
    List<InlineSpan> spans,
    TextStyle? baseStyle,
    EdgeInsets? padding,
    Color? borderColor,
    double borderWidth,
  ) {
    return Container(
      margin: padding ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: borderColor ?? Colors.grey,
            width: borderWidth,
          ),
        ),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      child: RichText(
        text: TextSpan(
          children: spans,
          style: (baseStyle ?? const TextStyle()).copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  static Widget _buildCodeBlock(
    List<InlineSpan> spans,
    TextStyle? baseStyle,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          children: spans,
          style: (baseStyle ?? const TextStyle()).copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  static Widget _buildImage(String url, double? maxWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: Colors.grey.withValues(alpha: 0.2),
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  static AlignmentGeometry _getAlignment(String align) {
    switch (align) {
      case 'center':
        return Alignment.center;
      case 'right':
        return Alignment.centerRight;
      case 'justify':
        return Alignment.centerLeft; // Flutter doesn't have justify
      default:
        return Alignment.centerLeft;
    }
  }
}
