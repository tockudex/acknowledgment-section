--[[
acknowledgments-section – move "acknowledgments" into document metadata (Quarto yaml header)

Copyright: © 2026 tockudex
License:   MIT – see LICENSE file for details
]]
local stringify = (require 'pandoc.utils').stringify
local section_identifiers = {
  acknowledgments = true,
}
local collected = {}
--- The level of the highest heading that was seen so far. Abstracts
--- must be at or above this level to prevent nested sections from being
--- treated as metadata. Only top-level sections should become metadata.
local toplevel = 6

--- Extract acknowledgments from a list of blocks.
local function acknowledgments_from_blocklist (blocks)
  local body_blocks = {}
  local looking_at_section = false

  for _, block in ipairs(blocks) do
    if block.t == 'Header' and block.level <= toplevel then
      toplevel = block.level
      if section_identifiers[block.identifier] then
        looking_at_section = block.identifier
        collected[looking_at_section] = {}
      else
        looking_at_section = false
        body_blocks[#body_blocks + 1] = block
      end
    else
      body_blocks[#body_blocks + 1] = block
    end
  end

  return body_blocks
end

Pandoc = function (doc)
  local meta = doc.meta

  -- configure
  section_identifiers_list =
    (doc.meta['acknowledgments-section'] or {})['section-identifiers']
  if section_identifiers_list and #section_identifiers_list > 0 then
    section_identifiers = {}
    for i, ident in ipairs(section_identifiers_list) do
      section_identifiers[stringify(ident)] = true
    end
  end
  -- unset config in meta
  doc.meta['acknowledgments-section'] = nil

  local blocks = {}
  if PANDOC_VERSION >= {2,17} then
    -- Walk all block lists by default
    blocks = doc.blocks:walk{Blocks = acknowledgments_from_blocklist}
  elseif PANDOC_VERSION >= {2,9,2} then
    -- Do the same with pandoc versions that don't have walk methods but the
    -- `walk_block` function.
    blocks = pandoc.utils.walk_block(
      pandoc.Div(doc.blocks),
      {Blocks = acknowledgments_from_blocklist}
    ).content
  else
    -- otherwise, just check the top-level block-list
    blocks = acknowledgments_from_blocklist(doc.blocks)
  end
  for metakey in pairs(section_identifiers) do
    metakey = stringify(metakey)
    local acknowledgments = collected[metakey]
    if not meta[metakey] and acknowledgments and #acknowledgments > 0 then
      meta[metakey] = pandoc.MetaBlocks(acknowledgments)
    end
  end
  return pandoc.Pandoc(blocks, meta)
end
