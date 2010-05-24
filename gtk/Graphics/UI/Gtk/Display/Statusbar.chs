{-# LANGUAGE CPP #-}
-- -*-haskell-*-
--  GIMP Toolkit (GTK) Widget Statusbar
--
--  Author : Axel Simon
--
--  Created: 23 May 2001
--
--  Copyright (C) 1999-2005 Axel Simon
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2.1 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
-- |
-- Maintainer  : gtk2hs-users@lists.sourceforge.net
-- Stability   : provisional
-- Portability : portable (depends on GHC)
--
-- Report messages of minor importance to the user
--
module Graphics.UI.Gtk.Display.Statusbar (
-- * Detail
-- 
-- | A 'Statusbar' is usually placed along the bottom of an application's main
-- 'Window'. It may provide a regular commentary of the application's status
-- (as is usually the case in a web browser, for example), or may be used to
-- simply output a message when the status changes, (when an upload is complete
-- in an FTP client, for example). It may also have a resize grip (a triangular
-- area in the lower right corner) which can be clicked on to resize the window
-- containing the statusbar.
--
-- Status bars in Gtk+ maintain a stack of messages. The message at the top
-- of the each bar's stack is the one that will currently be displayed.
--
-- Any messages added to a statusbar's stack must specify a /context_id/
-- that is used to uniquely identify the source of a message. This context_id
-- can be generated by 'statusbarGetContextId', given a message and the
-- statusbar that it will be added to. Note that messages are stored in a
-- stack, and when choosing which message to display, the stack structure is
-- adhered to, regardless of the context identifier of a message.
--
-- Status bars are created using 'statusbarNew'.
--
-- Messages are added to the bar's stack with 'statusbarPush'.
--
-- The message at the top of the stack can be removed using 'statusbarPop'.
-- A message can be removed from anywhere in the stack if its message_id was
-- recorded at the time it was added. This is done using 'statusbarRemove'.

-- * Class Hierarchy
-- |
-- @
-- |  'GObject'
-- |   +----'Object'
-- |         +----'Widget'
-- |               +----'Container'
-- |                     +----'Box'
-- |                           +----'HBox'
-- |                                 +----Statusbar
-- @

-- * Types
  Statusbar,
  StatusbarClass,
  castToStatusbar, gTypeStatusbar,
  toStatusbar,
  ContextId,
  MessageId,

-- * Constructors
  statusbarNew,

-- * Methods
  statusbarGetContextId,
  statusbarPush,
  statusbarPop,
  statusbarRemove,
  statusbarSetHasResizeGrip,
  statusbarGetHasResizeGrip,

-- * Attributes
  statusbarHasResizeGrip,

-- * Signals
  textPopped,
  textPushed,

-- * Deprecated
#ifndef DISABLE_DEPRECATED
  onTextPopped,
  afterTextPopped,
  onTextPushed,
  afterTextPushed,
#endif
  ) where

import Control.Monad	(liftM)

import System.Glib.FFI
import System.Glib.UTFString
import System.Glib.Attributes
import Graphics.UI.Gtk.Abstract.Object	(makeNewObject)
{#import Graphics.UI.Gtk.Types#}
{#import Graphics.UI.Gtk.Signals#}

{# context lib="gtk" prefix="gtk" #}

--------------------
-- Constructors

-- | Creates a new 'Statusbar' ready for messages.
--
statusbarNew :: IO Statusbar
statusbarNew =
  makeNewObject mkStatusbar $
  liftM (castPtr :: Ptr Widget -> Ptr Statusbar) $
  {# call unsafe statusbar_new #}

--------------------
-- Methods

type ContextId = {#type guint#}

-- | Returns a new context identifier, given a description of the actual
-- context. This id can be used to later remove entries form the Statusbar.
--
statusbarGetContextId :: StatusbarClass self => self
 -> String       -- ^ @contextDescription@ - textual description of what context the
                 -- new message is being used in.
 -> IO ContextId -- ^ returns an id that can be used to later remove entries
                 -- ^ from the Statusbar.
statusbarGetContextId self contextDescription =
  withUTFString contextDescription $ \contextDescriptionPtr ->
  {# call unsafe statusbar_get_context_id #}
    (toStatusbar self)
    contextDescriptionPtr

newtype MessageId = MessageId {#type guint#}

-- | Pushes a new message onto the Statusbar's stack. It will
-- be displayed as long as it is on top of the stack.
--
statusbarPush :: StatusbarClass self => self
 -> ContextId    -- ^ @contextId@ - the message's context id, as returned by
                 -- 'statusbarGetContextId'.
 -> String       -- ^ @text@ - the message to add to the statusbar.
 -> IO MessageId -- ^ returns the message's new message id for use with
                 -- 'statusbarRemove'.
statusbarPush self contextId text =
  liftM MessageId $
  withUTFString text $ \textPtr ->
  {# call statusbar_push #}
    (toStatusbar self)
    contextId
    textPtr

-- | Removes the topmost message that has the correct context.
--
statusbarPop :: StatusbarClass self => self
 -> ContextId   -- ^ @contextId@ - the context identifier used when the
                -- message was added.
 -> IO ()
statusbarPop self contextId =
  {# call statusbar_pop #}
    (toStatusbar self)
     contextId

-- | Forces the removal of a message from a statusbar's stack. The exact
-- @contextId@ and @messageId@ must be specified.
--
statusbarRemove :: StatusbarClass self => self
 -> ContextId -- ^ @contextId@ - a context identifier.
 -> MessageId -- ^ @messageId@ - a message identifier, as returned by
              -- 'statusbarPush'.
 -> IO ()
statusbarRemove self contextId (MessageId messageId) =
  {# call statusbar_remove #}
    (toStatusbar self)
    contextId
    messageId

-- | Sets whether the statusbar has a resize grip. @True@ by default.
--
statusbarSetHasResizeGrip :: StatusbarClass self => self -> Bool -> IO ()
statusbarSetHasResizeGrip self setting =
  {# call statusbar_set_has_resize_grip #}
    (toStatusbar self)
    (fromBool setting)

-- | Returns whether the statusbar has a resize grip.
--
statusbarGetHasResizeGrip :: StatusbarClass self => self -> IO Bool
statusbarGetHasResizeGrip self =
  liftM toBool $
  {# call unsafe statusbar_get_has_resize_grip #}
    (toStatusbar self)

--------------------
-- Attributes

-- | Whether the statusbar has a grip for resizing the toplevel window.
--
-- Default value: @True@
--
statusbarHasResizeGrip :: StatusbarClass self => Attr self Bool
statusbarHasResizeGrip = newAttr
  statusbarGetHasResizeGrip
  statusbarSetHasResizeGrip

--------------------
-- Signals

-- %hash c:4eb7 d:d0ef
-- | Is emitted whenever a new message gets pushed onto a statusbar's stack.
--
textPushed :: StatusbarClass self => Signal self (ContextId -> String -> IO ())
textPushed = Signal (\a self user -> connect_WORD_STRING__NONE "text_pushed" a self (\w s -> user (fromIntegral w) s))

-- %hash c:2614 d:c1d2
-- | Is emitted whenever a new message is popped off a statusbar's stack.
--
textPopped :: StatusbarClass self => Signal self (ContextId -> String -> IO ())
textPopped = Signal (\a self user -> connect_WORD_STRING__NONE "text_popped" a self (\w s -> user (fromIntegral w) s))

--------------------
-- Deprecated Signals

#ifndef DISABLE_DEPRECATED
-- | Called if a message is removed.
--
onTextPopped, afterTextPopped :: StatusbarClass self => self
 -> (ContextId -> String -> IO ())
 -> IO (ConnectId self)
onTextPopped self user = connect_WORD_STRING__NONE "text-popped" False self (user . fromIntegral)
afterTextPopped self user = connect_WORD_STRING__NONE "text-popped" True self (user . fromIntegral)

-- | Called if a message is pushed on top of the
-- stack.
--
onTextPushed, afterTextPushed :: StatusbarClass self => self
 -> (ContextId -> String -> IO ())
 -> IO (ConnectId self)
onTextPushed self user = connect_WORD_STRING__NONE "text-pushed" False self (user . fromIntegral)
afterTextPushed self user = connect_WORD_STRING__NONE "text-pushed" True self (user . fromIntegral)
#endif