"""px.snippets_helper"""

# See ~/.vim/UltiSnips/python.snippets

import vim  # type: ignore
try:
    import typing
    if typing.TYPE_CHECKING:
        import pynvim
        vim = pynvim.Nvim(...)  # type: ignore
except ImportError:
    pass


def snip_expand(snip, jump_pos=1, jump_forward=False):
    """A post-jump action to expand the nested snippet.

    Example:
    ```
    post_jump "snippets_helper.snip_expand(snip, 1)"
    snippet Nested
    print: Inner$1
    endsnippet
    snippet Inner
    "Inner Snippet"
    endsnippet
    ```

    See 'snippets-aliasing' in the Ultisnips doc.
    """
    if snip.tabstop != jump_pos:
        return
    vim.eval(r'feedkeys("\<C-R>=UltiSnips#ExpandSnippet()\<CR>")')
    if jump_forward:
        vim.eval(r'feedkeys("\<C-R>=UltiSnips#JumpForwards()\<CR>")')


__all__ = ('snip_expand', )
