package process_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"code.cloudfoundry.org/cfdev/process"
)

var _ = Describe("LinuxKit process", func() {
	It("builds a command", func() {
		linuxkit := process.LinuxKit{
			ImagePath:   "/home-dir/.cfdev/image",
			StatePath:   "/home-dir/.cfdev/state",
			BoshISOPath: "/home-dir/.cfdev/bosh.iso",
		}
		start := linuxkit.Command()

		Expect(start.Path).To(HaveSuffix("linuxkit"))
		Expect(start.Args).To(ConsistOf(
			"linuxkit", "run", "hyperkit",
			"-console-file",
			"-networking=vpnkit",
			"-disk", "size=10G",
			"-disk", "file=/home-dir/.cfdev/bosh.iso",
			"-state", "/home-dir/.cfdev/state",
			"--uefi", "/home-dir/.cfdev/image",
		))
		Expect(start.SysProcAttr.Setpgid).To(BeTrue())
	})
})