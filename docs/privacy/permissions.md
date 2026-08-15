# Android Permissions

The initial app requests no dangerous Android permissions. It opens HTTPS and `mailto` destinations through user-selected external applications. There is no background location, camera, microphone, contacts, phone, SMS, broad storage, advertising ID, or notification permission.

Every future permission requires a feature justification, least-privilege design, denial behavior, privacy-map update, and device test before merge.
