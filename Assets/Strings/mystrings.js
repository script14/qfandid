var appVersion = `0.8.3 open beta`

var aboutQt = `### About Qt\n
This program uses Qt version 5.15.2.\n
Qt is a C++ toolkit for cross-platform application development.\n
Qt provides single-source portability across all major desktop operating systems. It is also available for embedded Linux and other embedded and mobile operating systems.\n
Qt is available under multiple licensing options designed to accommodate the needs of our various users.\n
Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial software where you do not want to share any source code with third parties or otherwise cannot comply with the terms of GNU (L)GPL.\n
Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply with the terms and conditions of the respective licenses.\n
Please see qt.io/licensing for an overview of Qt licensing.\n
Copyright (C) 2020 The Qt Company Ltd and other contributors.\n
Qt and the Qt logo are trademarks of The Qt Company Ltd.\n
Qt is The Qt Company Ltd product developed as an open source project. See qt.io for more information\n
`

var aboutqFandid = `### About qFandid\n
qFandid is a Qt frontend for the social media Fandid created by Krestek.\n
qFandid is free/libre open source software released under GPL. The source code is available in GitLab at https://gitlab.com/exuberantdev/qfandid\n
You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses
`

var credits = `### Team Members:
- Founder and Server Developer: Krestek
- qFandid Developer and Lead Admin: Sienhopist
- Admins: 4Four, Azuri Minty Satan, CrackpipeCat, sabs546, ShittyPerson, Tennie

### Thanks to:
- CrackpipeCat: For creating every avatar.
- Azuri Minty Satan: For color advise.
- ExuberantCat: For creating the first ever logo of Fandid.
- Ragan Clack: For creating the image loading GIF.
- Dictator Jibril: For creating a banner for our Patreon page.
- Bread: For creating a banner for our Facebook page.

### Third-party libraries used:
- Blurhash: for generating blurred images before the real image is downloaded. https://github.com/woltapp/blurhash
`

var changelog = `Changelog:
` + appVersion + `
- Small background optimizations for faster notification retrieval
- PC: App will follow system font
- Less waiting time before loading the next batch of posts, comments, etc
- Fixed hyperlinks not being escaped when sharing text
- Added option to copy all text to clipboard
- New Mod and Placeholder avatars
- PC: Fixed comment pictures disappearing in fullscreen mode
- Fixed group not being set in post creator when you press the post button inside a group before the group is loaded
- Added new post style to match the website
- Added toggles for enabling and disabling external notifications for direct messages and comments
- Android: Improved back button not working sometimes. However, the bug will likely be present on devices using the Swiftkey keyboard
- Android: Saved images will now go in a "Fandid" folder in the device's pictures directory
- PC: Added dragging and dropping images from your file manager
- Added simple markdown support that works like this

        \*italic\*

        \*\*bold\*\*

        \*\*\*bold italic\*\*\*

        ^^small text^^

        --subscript--

        ++supscript++

        \_\_underline\_\_

        \~\~strikethrough\~\~

        \`\`\`
        Code block that ignores the special characters above
        The contents of the code block must be on a new line from the \`\`\` character group
        See example below
        \`\`\`

        \`\`\`
        \*\*\*This bold italic will be ignored and the asterisks will be visible\*\*\*
        \`\`\`

- Android: Opening a DM or comment will automatically cancel its active notification if one exists
- Android: Added sharing images from other apps
- Android: Added notifications when saving images and increased priority of DM notifications. However, if you already have the app installed, you will have to uninstall and reinstall it for DM notifications to have higher priority
- Windows: Added an update button that can be used from the settings page. It will launch the maintenance and automatically update the app if updates exist. It only works if you installed qFandid through the online Windows installer provided in the Fandid home webpage
- Android: Fixed saved images not being visible in other apps
- PC: App will now restore its previous window size on launch
- Android: App now uses an Android Java native file dialog which allows using other apps to choose images. It also fixes the problem with choosing images on Motorola smartphones
`
