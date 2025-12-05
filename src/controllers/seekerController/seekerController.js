import { StatusCodes } from 'http-status-codes'
import { seekerModel } from '~/models/seekerModel/seekerModel'
import { authModel } from '~/models/authModel/authModel'

const viewDashboard = (req, res) => {
    res.render('seeker/dashboard.ejs', { title: 'Seeker Dashboard', user: req.session.user })
}



const viewProfile = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        const seeker = await seekerModel.getProfile(userId)
        const availableSkills = await seekerModel.getAvailableSkills()

        if (!seeker) {
            return res.redirect('/auth/login')
        }

        res.render('seeker/profile.ejs', {
            title: 'My Profile',
            user: req.session.user,
            seeker: seeker,
            availableSkills: availableSkills
        })
    } catch (err) {
        next(err)
    }
}

const handleUpdateProfile = async (req, res, next) => {
    try {
        const userId = req.session.user.id
            const { FirstName, LastName, PhoneNumber, ExperienceLevel, CurrentLocation, ProfileSummary, DateOfBirth, Skills } = req.body

            const profileData = {
                FirstName,
                LastName,
                PhoneNumber,
                CurrentLocation,
                ProfileSummary,
                ExperienceLevel: ExperienceLevel,
                DateOfBirth: DateOfBirth || null
            }

        await seekerModel.updateProfile(userId, profileData)

        if (Skills) {
            const skillsArray = JSON.parse(Skills)
            await seekerModel.updateSkills(userId, skillsArray)
        }

        res.redirect('/seeker/profile')
    } catch (err) {
        next(err)
    }
}

const getSkills = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        const skills = await seekerModel.getSkills(userId)
        res.status(StatusCodes.OK).json({ success: true, skills })
    } catch (err) {
        next(err)
    }
}

const addSkill = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        const { SkillName, ProficiencyLevel, YearOfExperience } = req.body

        await seekerModel.addSkill(userId, {
            SkillName,
            ProficiencyLevel,
            YearOfExperience
        })

        res.redirect('/seeker/profile')
    } catch (err) {
        next(err)
    }
}

const deleteSkill = async (req, res, next) => {
    try {
        const userId = req.session.user.id
        const { SkillID } = req.body

        await seekerModel.deleteSkill(userId, SkillID)

        res.redirect('/seeker/profile')
    } catch (err) {
        next(err)
    }
}


export const seekerController = {
    viewDashboard,
    viewProfile,
    handleUpdateProfile,
    getSkills,
    addSkill,
    deleteSkill
}
