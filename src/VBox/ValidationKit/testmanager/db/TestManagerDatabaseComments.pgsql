COMMENT ON COLUMN SystemLog.tsCreated IS
  'When this was logged.';


COMMENT ON COLUMN SystemLog.sEvent IS
  'The event type.
This is a 8 character string identifier so that we don''t need to change
some enum type everytime we introduce a new event type.';


COMMENT ON COLUMN SystemLog.sLogText IS
  'The log text.';


COMMENT ON TABLE Users IS
  'Test manager users.

This is mainly for doing simple access checks before permitting access to
the test manager.  This needs to be coordinated with
apache/ldap/Oracle-Single-Sign-On.

The main purpose, though, is for tracing who changed the test config and
analysis data.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.';


COMMENT ON COLUMN Users.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN Users.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN Users.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN Users.sUsername IS
  'User name.';


COMMENT ON COLUMN Users.sEmail IS
  'The email address of the user.';


COMMENT ON COLUMN Users.sFullName IS
  'The full name.';


COMMENT ON COLUMN Users.sLoginName IS
  'The login name used by apache.';


COMMENT ON TABLE GlobalResources IS
  'Global resource configuration.

For example an iSCSI target.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.';


COMMENT ON COLUMN GlobalResources.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN GlobalResources.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN GlobalResources.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN GlobalResources.sName IS
  'The name of the resource.';


COMMENT ON COLUMN GlobalResources.sDescription IS
  'Optional resource description.';


COMMENT ON COLUMN GlobalResources.fEnabled IS
  'Indicates whether this resource is currently enabled (online).';


COMMENT ON TABLE BuildSources IS
  'Build sources.

This is used by a scheduling group to select builds and the default
Validation Kit from the Builds table.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.

@todo Any better way of representing this so we could more easily
      join/whatever when searching for builds?';


COMMENT ON COLUMN BuildSources.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN BuildSources.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN BuildSources.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN BuildSources.sName IS
  'The name of the build source.';


COMMENT ON COLUMN BuildSources.sDescription IS
  'Description.';


COMMENT ON COLUMN BuildSources.sProduct IS
  'Which product.
ASSUME that it is okay to limit a build source to a single product.';


COMMENT ON COLUMN BuildSources.sBranch IS
  'Which branch.
ASSUME that it is okay to limit a build source to a branch.';


COMMENT ON COLUMN BuildSources.asTypes IS
  'Build types to include, all matches if NULL.
@todo Weighting the types would be nice in a later version.';


COMMENT ON COLUMN BuildSources.asOsArches IS
  'Array of the ''sOs.sCpuArch'' to match, all matches if NULL.
See KBUILD_OSES in kBuild for a list of standard target OSes, and
KBUILD_ARCHES for a list of standard architectures.

@remarks See marks on ''os-agnostic'' and ''noarch'' in BuildCategories.';


COMMENT ON COLUMN BuildSources.iFirstRevision IS
  'The first subversion tree revision to match, no lower limit if NULL.';


COMMENT ON COLUMN BuildSources.iLastRevision IS
  'The last subversion tree revision to match, no upper limit if NULL.';


COMMENT ON TABLE TestCases IS
  'Test case configuration.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.';


COMMENT ON COLUMN TestCases.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestCases.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestCases.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestCases.sName IS
  'The name of the test case.';


COMMENT ON COLUMN TestCases.sDescription IS
  'Optional test case description.';


COMMENT ON COLUMN TestCases.fEnabled IS
  'Indicates whether this test case is currently enabled.';


COMMENT ON COLUMN TestCases.cSecTimeout IS
  'Default test case timeout given in seconds.';


COMMENT ON COLUMN TestCases.sTestBoxReqExpr IS
  'Default TestBox requirement expression (python boolean expression).
All the scheduler properties are available for use with the same names
as in that table.
If NULL everything matches.';


COMMENT ON COLUMN TestCases.sBuildReqExpr IS
  'Default build requirement expression (python boolean expression).
The following build properties are available: sProduct, sBranch,
sType, asOsArches, sVersion, iRevision, uidAuthor and idBuild.
If NULL everything matches.';


COMMENT ON COLUMN TestCases.sBaseCmd IS
  'The base command.
String suitable for executing in bourne shell with space as separator
(IFS). References to @BUILD_BINARIES@ will be replaced WITH the content
of the Builds(sBinaries) field.';


COMMENT ON COLUMN TestCases.sTestSuiteZips IS
  'Comma separated list of test suite zips (or tars) that the testbox will
need to download and expand prior to testing.
If NULL the current test suite of the scheduling group will be used (the
scheduling group will have an optional test suite build queue associated
with it).  The current test suite can also be referenced by
@VALIDATIONKIT_ZIP@ in case more downloads are required.  Files may also be
uploaded to the test manager download area, in which case the
@DOWNLOAD_BASE_URL@ prefix can be used to refer to this area.';


COMMENT ON TABLE TestCaseArgs IS
  'Test case argument list variations.

For example, we have a test case that does a set of tests on a virtual
machine.  To get better code/feature coverage of this testcase we wish to
run it with different guest hardware configuration.  The test case may do
the same stuff, but the guest OS as well as the VMM may react differently to
the hardware configurations and uncover issues in the VMM, device emulation
or other places.

Typical hardware variations are:
     - guest memory size (RAM),
     - guest video memory size (VRAM),
     - virtual CPUs / cores / threads,
     - virtual chipset
     - virtual network interface card (NIC)
     - USB 1.1, USB 2.0, no USB

The TM web UI will help the user create a reasonable set of permutations
of these parameters, the user specifies a maximum and the TM uses certain
rules together with random selection to generate the desired number.  The
UI will also help suggest fitting testbox requirements according to the
RAM/VRAM sizes and the virtual CPU counts.  The user may then make
adjustments to the suggestions before commit them.

Alternatively, the user may also enter all the permutations without any
help from the UI.

Note! All test cases has at least one entry in this table, even if it is
empty, because testbox requirements are specified thru this.

Querying the valid parameter lists for a testase this way:
     SELECT * ... WHERE idTestCase = TestCases.idTestCase
                    AND tsExpire     > <when>
                    AND tsEffective <= <when>;

Querying the valid parameter list for the latest generation can be
simplified by just checking tsExpire date:
     SELECT * ... WHERE idTestCase = TestCases.idTestCase
                    AND tsExpire    == TIMESTAMP WITH TIME ZONE ''infinity'';

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.';


COMMENT ON COLUMN TestCaseArgs.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestCaseArgs.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestCaseArgs.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestCaseArgs.sArgs IS
  'The additional arguments.
String suitable for bourne shell style argument parsing with space as
separator (IFS).  References to @BUILD_BINARIES@ will be replaced with
the content of the Builds(sBinaries) field.';


COMMENT ON COLUMN TestCaseArgs.cSecTimeout IS
  'Optional test case timeout given in seconds.
If NULL, the TestCases.cSecTimeout field is used instead.';


COMMENT ON COLUMN TestCaseArgs.sTestBoxReqExpr IS
  'Additional TestBox requirement expression (python boolean expression).
All the scheduler properties are available for use with the same names
as in that table.  This is checked after first checking the requirements
in the TestCases.sTestBoxReqExpr field.';


COMMENT ON COLUMN TestCaseArgs.sBuildReqExpr IS
  'Additional build requirement expression (python boolean expression).
The following build properties are available: sProduct, sBranch,
sType, asOsArches, sVersion, iRevision, uidAuthor and idBuild. This is
checked after first checking the requirements in the
TestCases.sBuildReqExpr field.';


COMMENT ON COLUMN TestCaseArgs.cGangMembers IS
  'Number of testboxes required (gang scheduling).';


COMMENT ON INDEX TestCaseArgsLookupIdx IS
  'The arguments are part of the primary key for several reasons.
No duplicate argument lists (makes no sense - if you want to prioritize
argument lists, we add that explicitly).  This may hopefully enable us
to more easily check coverage later on, even when the test case is
reconfigured with more/less permutations.';


COMMENT ON TABLE TestCaseDeps IS
  'Test case dependencies (N:M)

This effect build selection.  The build must have passed all runs of the
given prerequisite testcase (idTestCasePreReq) and executed at a minimum one
argument list variation.

This should also affect scheduling order, if possible at least one
prerequisite testcase variation should be place before the specific testcase
in the scheduling queue.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestCaseDeps.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestCaseDeps.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestCaseDeps.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON TABLE TestCaseGlobalRsrcDeps IS
  'Test case dependencies on global resources (N:M)

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestCaseGlobalRsrcDeps.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestCaseGlobalRsrcDeps.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestCaseGlobalRsrcDeps.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON TABLE TestGroups IS
  'Test Group - A collection of test cases.

This is for simplifying test configuration by working with a few groups
instead of a herd of individual testcases.  It may also be used for creating
test suites for certain areas (like guest additions) or tasks (like
performance measurements).

A test case can be member of any number of test groups.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestGroups.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestGroups.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestGroups.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestGroups.sName IS
  'The name of the scheduling group.';


COMMENT ON COLUMN TestGroups.sDescription IS
  'Optional group description.';


COMMENT ON TABLE TestGroupMembers IS
  'The N:M relation ship between test case configurations and test groups.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestGroupMembers.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestGroupMembers.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestGroupMembers.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestGroupMembers.iSchedPriority IS
  'Test case scheduling priority.
Higher number causes the test case to be run more frequently.
@sa SchedGroupMembers.iSchedPriority
@todo Not sure we want to keep this...';


COMMENT ON TABLE SchedGroups IS
  'Scheduling group (aka. testbox partitioning) configuration.

A testbox is associated with exactly one scheduling group.  This association
can be changed, of course.  If we (want to) retire a group which still has
testboxes associated with it, these will be moved to the ''default'' group.

The TM web UI will make sure that a testbox is always in a group and that
the default group cannot be deleted.

A scheduling group combines several things:
     - A selection of builds to test (via idBuildSrc).
     - A collection of test groups to test with (via SchedGroupMembers).
     - A set of testboxes to test on (via TestBoxes.idSchedGroup).

In additions there is an optional source of fresh test suite builds (think
VBoxTestSuite) as well as scheduling options.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN SchedGroups.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN SchedGroups.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN SchedGroups.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)
@note This is NULL for the default group.';


COMMENT ON COLUMN SchedGroups.sName IS
  'The name of the scheduling group.';


COMMENT ON COLUMN SchedGroups.sDescription IS
  'Optional group description.';


COMMENT ON COLUMN SchedGroups.fEnabled IS
  'Indicates whether this group is currently enabled.';


COMMENT ON COLUMN SchedGroups.enmScheduler IS
  'The scheduler to use.
This is for when we later desire different scheduling that the best
effort stuff provided by the initial implementation.';


COMMENT ON TABLE SchedGroupMembers IS
  'N:M relationship between scheduling groups and test groups.

Several scheduling parameters are associated with this relationship.

The test group dependency (idTestGroupPreReq) can be used in the same way as
TestCaseDeps.idTestCasePreReq, only here on test group level.  This means it
affects the build selection.  The builds needs to have passed all test runs
the prerequisite test group and done at least one argument variation of each
test case in it.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN SchedGroupMembers.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN SchedGroupMembers.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN SchedGroupMembers.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN SchedGroupMembers.iSchedPriority IS
  'The scheduling priority if the test group.
Higher number causes the test case to be run more frequently.
@sa TestGroupMembers.iSchedPriority';


COMMENT ON COLUMN SchedGroupMembers.bmHourlySchedule IS
  'When during the week this group is allowed to start running, NULL means
there are no constraints.
Each bit in the bitstring represents one hour, with bit 0 indicating the
midnight hour on a monday.';


COMMENT ON TYPE TestBoxCmd_T IS
  'Testbox commands.';


COMMENT ON TYPE LomKind_T IS
  'The kind of lights out management on a testbox.';


COMMENT ON TABLE TestBoxes IS
  'Testbox configurations.

The testboxes are identified by IP and the system UUID if available. Should
the IP change, the testbox will be refused at sign on and the testbox
sheriff will have to update it''s IP.

@todo Implement the UUID stuff. Get it from DMI, UEFI or whereever.
      Mismatching needs to be logged somewhere...

To query the currently valid configuration:
    SELECT ... WHERE id = idTestBox AND tsExpire = TIMESTAMP WITH TIME ZONE ''infinity'';

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestBoxes.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestBoxes.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestBoxes.uidAuthor IS
  'The user id of the one who created/modified this entry.
When modified automatically by the testbox, NULL is used.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestBoxes.uuidSystem IS
  'The system or firmware UUID.
This uniquely identifies the testbox when talking to the server.  After
SIGNON though, the testbox will also provide idTestBox and ip to
establish its identity beyond doubt.';


COMMENT ON COLUMN TestBoxes.sName IS
  'The testbox name.
Usually similar to the DNS name.';


COMMENT ON COLUMN TestBoxes.sDescription IS
  'Optional testbox description.
Intended for describing the box as well as making other relevant notes.';


COMMENT ON COLUMN TestBoxes.fEnabled IS
  'Indicates whether this testbox is enabled.
A testbox gets disabled when we''re doing maintenance, debugging a issue
that happens only on that testbox, or some similar stuff.  This is an
alternative to deleting the testbox.';


COMMENT ON COLUMN TestBoxes.enmLomKind IS
  'The kind of lights-out-management.';


COMMENT ON COLUMN TestBoxes.sOs IS
  'Same abbrieviations as kBuild, see KBUILD_OSES.';


COMMENT ON COLUMN TestBoxes.sOsVersion IS
  'Informational, no fixed format.';


COMMENT ON COLUMN TestBoxes.sCpuVendor IS
  'Same as CPUID reports (GenuineIntel, AuthenticAMD, CentaurHauls, ...).';


COMMENT ON COLUMN TestBoxes.sCpuArch IS
  'Same as kBuild - x86, amd64, ... See KBUILD_ARCHES.';


COMMENT ON COLUMN TestBoxes.cCpus IS
  'Number of CPUs, CPU cores and CPU threads.';


COMMENT ON COLUMN TestBoxes.fCpuHwVirt IS
  'Set if capable of hardware virtualization.';


COMMENT ON COLUMN TestBoxes.fCpuNestedPaging IS
  'Set if capable of nested paging.';


COMMENT ON COLUMN TestBoxes.fCpu64BitGuest IS
  'Set if CPU capable of 64-bit (VBox) guests.';


COMMENT ON COLUMN TestBoxes.fChipsetIoMmu IS
  'Set if chipset with usable IOMMU (VT-d / AMD-Vi).';


COMMENT ON COLUMN TestBoxes.cMbMemory IS
  'The (approximate) memory size in megabytes (rounded down to nearest 4 MB).';


COMMENT ON COLUMN TestBoxes.cMbScratch IS
  'The amount of scratch space in megabytes (rounded down to nearest 64 MB).';


COMMENT ON COLUMN TestBoxes.iTestBoxScriptRev IS
  'The testbox script revision number, serves the purpose of a version number.
Probably good to have when scheduling upgrades as well for status purposes.';


COMMENT ON COLUMN TestBoxes.iPythonHexVersion IS
  'The python sys.hexversion (layed out as of 2.7).
Good to know which python versions we need to support.';


COMMENT ON COLUMN TestBoxes.enmPendingCmd IS
  'Pending command.
@note We put it here instead of in TestBoxStatuses to get history.';


COMMENT ON INDEX TestBoxesUuidIdx IS
  'Nested paging requires hardware virtualization.';


COMMENT ON TABLE FailureCategories IS
  'Failure categories.

This is for organizing the failure reasons.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN FailureCategories.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN FailureCategories.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN FailureCategories.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN FailureCategories.sShort IS
  'The short category description.
For combo boxes and other selection lists.';


COMMENT ON COLUMN FailureCategories.sFull IS
  'Full description
For cursor-over-poppups for instance.';


COMMENT ON TABLE FailureReasons IS
  'Failure reasons.

When analysing a test failure, the testbox sheriff will try assign a fitting
reason for the failure.  This table is here to help the sheriff in his/hers
job as well as developers looking checking if their changes affected the
test results in any way.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN FailureReasons.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN FailureReasons.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN FailureReasons.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN FailureReasons.sShort IS
  'The short failure description.
For combo boxes and other selection lists.';


COMMENT ON COLUMN FailureReasons.sFull IS
  'Full failure description.';


COMMENT ON COLUMN FailureReasons.iTicket IS
  'Ticket number in the primary bugtracker.';


COMMENT ON COLUMN FailureReasons.asUrls IS
  'Other URLs to reports or discussions of the observed symptoms.';


COMMENT ON TABLE TestResultFailures IS
  'This is for tracking/discussing test result failures.

The rational for putting this is a separate table is that we need history on
this while TestResults does not.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN TestResultFailures.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN TestResultFailures.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN TestResultFailures.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN TestResultFailures.sComment IS
  'Optional comment.';


COMMENT ON TABLE BuildBlacklist IS
  'Table used to blacklist sets of builds.

The best usage example is a VMM developer realizing that a change causes the
host to panic, hang, or otherwise misbehave.  To prevent the testbox sheriff
from repeatedly having to reboot testboxes, the builds gets blacklisted
until there is a working build again.  This may mean adding an open ended
blacklist spec and then updating it with the final revision number once the
fix has been committed.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.

@todo Would be nice if we could replace the text strings below with a set of
      BuildCategories, or sore it in any other way which would enable us to
      do a negative join with build category...  The way it is specified
      now, it looks like we have to open a cursor of prospecitve builds and
      filter then thru this table one by one.

      Any better representation is welcome, but this is low prioirty for
      now, as it''s relatively easy to change this later one.';


COMMENT ON COLUMN BuildBlacklist.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN BuildBlacklist.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN BuildBlacklist.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)';


COMMENT ON COLUMN BuildBlacklist.sProduct IS
  'Which product.
ASSUME that it is okay to limit a blacklisting to a single product.';


COMMENT ON COLUMN BuildBlacklist.sBranch IS
  'Which branch.
ASSUME that it is okay to limit a blacklisting to a branch.';


COMMENT ON COLUMN BuildBlacklist.asTypes IS
  'Build types to include, all matches if NULL.';


COMMENT ON COLUMN BuildBlacklist.asOsArches IS
  'Array of the ''sOs.sCpuArch'' to match, all matches if NULL.
See KBUILD_OSES in kBuild for a list of standard target OSes, and
KBUILD_ARCHES for a list of standard architectures.

@remarks See marks on ''os-agnostic'' and ''noarch'' in BuildCategories.';


COMMENT ON COLUMN BuildBlacklist.iFirstRevision IS
  'The first subversion tree revision to blacklist.';


COMMENT ON COLUMN BuildBlacklist.iLastRevision IS
  'The last subversion tree revision to blacklist, no upper limit if NULL.';


COMMENT ON TABLE BuildCategories IS
  'Build categories.

The purpose of this table is saving space in the Builds table and hopefully
speed things up when selecting builds as well (compared to selecting on 4
text fields in the much larger Builds table).

Insert only table, no update, no delete.  History is not needed.';


COMMENT ON COLUMN BuildCategories.sProduct IS
  'Product.
The product name.  For instance ''VBox'' or ''VBoxTestSuite''.';


COMMENT ON COLUMN BuildCategories.sBranch IS
  'The branch name.';


COMMENT ON COLUMN BuildCategories.sType IS
  'The build type.
See KBUILD_BLD_TYPES in kBuild for a list of standard build types.';


COMMENT ON COLUMN BuildCategories.asOsArches IS
  'Array of the ''sOs.sCpuArch'' supported by the build.
See KBUILD_OSES in kBuild for a list of standard target OSes, and
KBUILD_ARCHES for a list of standard architectures.

@remarks ''os-agnostic'' is used if the build doesn''t really target any
         specific OS or if it targets all applicable OSes.
         ''noarch'' is used if the build is architecture independent or if
         all applicable architectures are handled.
         Thus, ''os-agnostic.noarch'' will run on all build boxes.

@note    The array shall be sorted ascendingly to prevent unnecessary duplicates!';


COMMENT ON TABLE Builds IS
  'The builds table contains builds from the tinderboxes and oaccasionally from
developers.

The tinderbox side could be fed by a batch job enumerating the build output
directories every so often, looking for new builds.  Or we could query them
from the tinderbox database.  Yet another alternative is making the
tinderbox server or client side software inform us about all new builds.

The developer builds are entered manually thru the TM web UI.  They are used
for subjecting new code to some larger scale testing before commiting,
enabling, or merging a private branch.

The builds are being selected from this table by the via the build source
specification that SchedGroups.idBuildSrc and
SchedGroups.idBuildSrcTestSuite links to.

@remarks This table stores history.  Never update or delete anything.  The
         equivalent of deleting is done by setting the ''tsExpire'' field to
         current_timestamp.  To select the currently valid entries use
         tsExpire = TIMESTAMP WITH TIME ZONE ''infinity''.';


COMMENT ON COLUMN Builds.tsCreated IS
  'When this build was created or entered into the database.
This remains unchanged';


COMMENT ON COLUMN Builds.tsEffective IS
  'When this row starts taking effect (inclusive).';


COMMENT ON COLUMN Builds.tsExpire IS
  'When this row stops being tsEffective (exclusive).';


COMMENT ON COLUMN Builds.uidAuthor IS
  'The user id of the one who created/modified this entry.
Non-unique foreign key: Users(uid)
@note This is NULL if added by a batch job / tinderbox.';


COMMENT ON COLUMN Builds.iRevision IS
  'The subversion tree revision of the build.';


COMMENT ON COLUMN Builds.sVersion IS
  'The product version number (suitable for RTStrVersionCompare).';


COMMENT ON COLUMN Builds.sLogUrl IS
  'The link to the tinderbox log of this build.';


COMMENT ON COLUMN Builds.sBinaries IS
  'Comma separated list of binaries.
The binaries have paths relative to the TESTBOX_PATH_BUILDS or full URLs.';


COMMENT ON COLUMN Builds.fBinariesDeleted IS
  'Set when the binaries gets deleted by the build quota script.';


COMMENT ON TABLE TestResultStrTab IS
  'String table for the test results.

This is a string cache for value names, test names and possible more, that
is frequently repated in the test results record for each test run.  The
purpose is not only to save space, but to make datamining queries faster by
giving them integer fields to work on instead of text fields.  There may
possibly be some benefits on INSERT as well as there are only integer
indexes.

Nothing is ever deleted from this table.

@note Should use a stored procedure to query/insert a string.';


COMMENT ON COLUMN TestResultStrTab.sValue IS
  'The string value.';


COMMENT ON COLUMN TestResultStrTab.tsCreated IS
  'Creation time stamp.';


COMMENT ON TYPE TestStatus_T IS
  'The status of a test (set / result).';


COMMENT ON TABLE TestResults IS
  'Test results - a recursive bundle of joy!

A test case will be created when the testdriver calls reporter.testStart and
concluded with reporter.testDone.  The testdriver (or it subordinates) can
use these methods to create nested test results.  For IPRT based test cases,
RTTestCreate, RTTestInitAndCreate and RTTestSub will both create new test
result records, where as RTTestSubDone, RTTestSummaryAndDestroy and
RTTestDestroy will conclude records.

By concluding is meant updating the status.  When the test driver reports
success, we check it against reported results. (paranoia strikes again!)

Nothing is ever deleted from this table.

@note    As seen below, several other tables associate data with a
         test result, and the top most test result is referenced by the
         test set.';


COMMENT ON COLUMN TestResults.tsCreated IS
  'Creation time stamp.  This may also be the timestamp of when the test started.';


COMMENT ON COLUMN TestResults.tsElapsed IS
  'The elapsed time for this test.
This is either reported by the directly (with some sanity checking) or
calculated (current_timestamp - created_ts).
@todo maybe use a nanosecond field here, check with what';


COMMENT ON COLUMN TestResults.cErrors IS
  'The error count.';


COMMENT ON COLUMN TestResults.enmStatus IS
  'The test status.';


COMMENT ON COLUMN TestResults.iNestingDepth IS
  'Nesting depth.';


COMMENT ON TABLE TestResultValues IS
  'Test result values.

A testdriver or subordinate may report a test value via
reporter.testValue(), while IPRT based test will use RTTestValue and
associates.

This is an insert only table, no deletes, no updates.';


COMMENT ON COLUMN TestResultValues.tsCreated IS
  'Creation time stamp.';


COMMENT ON COLUMN TestResultValues.lValue IS
  'The value.';


COMMENT ON COLUMN TestResultValues.iUnit IS
  'The unit.
@todo This is currently not defined properly. Will fix/correlate this
      with the other places we use unit (IPRT/testdriver/VMMDev).';


COMMENT ON TABLE TestResultFiles IS
  'Test result files.

A testdriver or subordinate may report a file by using
reporter.addFile() or reporter.addLogFile().

The files stored here as well as the primary log file will be processed by a
batch job and compressed if considered compressable.  Thus, TM will look for
files with a .gz/.bz2 suffix first and then without a suffix.

This is an insert only table, no deletes, no updates.';


COMMENT ON COLUMN TestResultFiles.tsCreated IS
  'Creation time stamp.';


COMMENT ON INDEX TestResultFilesIdx IS
  'The mime type for the file.
For instance: ''text/plain'',
              ''image/png'',
              ''video/webm'',
              ''text/xml''';


COMMENT ON TABLE TestResultMsgs IS
  'Test result message.

A testdriver or subordinate may report a message via the sDetails parameter
of the reporter.testFailure() method, while IPRT test cases will use
RTTestFailed, RTTestPrintf and their friends.  For RTTestPrintf, we will
ignore the more verbose message levels since these can also be found in one
of the logs.

This is an insert only table, no deletes, no updates.';


COMMENT ON COLUMN TestResultMsgs.tsCreated IS
  'Creation time stamp.';


COMMENT ON COLUMN TestResultMsgs.enmLevel IS
  'The message level.';


COMMENT ON TABLE TestSets IS
  'Test sets / Test case runs.

This is where we collect data about test runs.

@todo Not entirely sure where the ''test set'' term came from.  Consider
      finding something more appropriate.';


COMMENT ON COLUMN TestSets.tsConfig IS
  'The test config timestamp, used when reading test config.';


COMMENT ON COLUMN TestSets.tsCreated IS
  'When this test set was scheduled.
idGenTestBox is valid at this point.';


COMMENT ON COLUMN TestSets.tsDone IS
  'When this test completed, i.e. testing stopped.  This should only be set once.';


COMMENT ON COLUMN TestSets.enmStatus IS
  'The current status.';


COMMENT ON COLUMN TestSets.sBaseFilename IS
  'The base filename used for storing files related to this test set.
This is a path relative to wherever TM is dumping log files.  In order
to not become a file system test case, we will try not to put too many
hundred thousand files in a directory.  A simple first approach would
be to just use the current date (tsCreated) like this:
   TM_FILE_DIR/year/month/day/TestSets.idTestSet

The primary log file for the test is this name suffixed by ''.log''.

The files in the testresultfile table gets their full names like this:
   TM_FILE_DIR/sBaseFilename-testresultfile.id-TestResultStrTab(testresultfile.idStrFilename)

@remarks We store this explicitly in case we change the directly layout
         at some later point.';


COMMENT ON COLUMN TestSets.iGangMemberNo IS
  'The gang member number number, 0 is the leader.';


COMMENT ON INDEX TestSetsGangIdx IS
  'The test set of the gang leader, NULL if no gang involved.
@note This is set by the gang leader as well, so that we can find all
      gang members by WHERE idTestSetGangLeader = :id.';


COMMENT ON TYPE TestBoxState_T IS
  'TestBox state.

@todo Consider drawing a state diagram for this.';


COMMENT ON TABLE TestBoxStatuses IS
  'Testbox status table.

History is not planned on this table.';


COMMENT ON COLUMN TestBoxStatuses.tsUpdated IS
  'When this status was last updated.
This is updated everytime the testbox talks to the test manager, thus it
can easily be used to find testboxes which has stopped responding.

This is used for timeout calculation during gang-gathering, so in that
scenario it won''t be updated until the gang is gathered or we time out.';


COMMENT ON COLUMN TestBoxStatuses.enmState IS
  'The current state.';


COMMENT ON TABLE GlobalResourceStatuses IS
  'Global resource status, tracks which test set resources are allocated by.

History is not planned on this table.';


COMMENT ON COLUMN GlobalResourceStatuses.tsAllocated IS
  'When the allocation took place.';


COMMENT ON TABLE SchedQueues IS
  'Scheduler queue.

The queues are currently associated with a scheduling group, it could
alternative be changed to hook on to a testbox instead.  It depends on what
kind of scheduling method we prefer.  The former method aims at test case
thruput, making sacrifices in the hardware distribution area.  The latter is
more like the old buildbox style testing, making sure that each test case is
executed on each testbox.

When there are configuration changes, TM will regenerate the scheduling
queue for the affected scheduling groups.  We do not concern ourselves with
trying to continue at the approximately same queue position, we simply take
it from the top.

When a testbox ask for work, we will open a cursor on the queue and take the
first test in the queue that can be executed on that testbox.  The test will
be moved to the end of the queue (getting a new item_id).

If a test is manually changed to the head of the queue, the item will get a
item_id which is 1 lower than the head of the queue.  Unless someone does
this a couple of billion times, we shouldn''t have any trouble running out of
number space. :-)

Manually moving a test to the end of the queue is easy, just get a new
''item_id''.

History is not planned on this table.';


COMMENT ON COLUMN SchedQueues.bmHourlySchedule IS
  'The scheduling time constraints (see SchedGroupMembers.bmHourlySchedule).';


COMMENT ON COLUMN SchedQueues.tsConfig IS
  'When the queue entry was created and for which config is valid.
This is the timestamp that should be used when reading config info.';


COMMENT ON COLUMN SchedQueues.tsLastScheduled IS
  'When this status was last scheduled.
This is set to current_timestamp when moving the entry to the end of the
queue.  It''s initial value is unix-epoch.  Not entirely sure if it''s
useful beyond introspection and non-unique foreign key hacking.';


COMMENT ON COLUMN SchedQueues.cMissingGangMembers IS
  'The number of gang members still missing.

This saves calculating the number of missing members via selects like:
    SELECT COUNT(*) FROM TestSets WHERE idTestSetGangLeader = :idGang;
and
    SELECT cGangMembers FROM TestCaseArgs WHERE idGenTestCaseArgs = :idTest;
to figure out whether to remain in ''gather-gang''::TestBoxState_T.';


